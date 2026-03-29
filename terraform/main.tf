module "vpc" {
  source = "./modules/vpc"
}

module "compute" {
  source = "./modules/compute"

  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets

  jenkins_instance_type = "c7i-flex.large"
  ansible_instance_type = "t3.micro"
  ami_id                = "ami-05d2d839d4f73aafb"

  region       = var.region
  cluster_name = var.cluster_name
}


module "eks" {
  source = "./modules/eks"

  cluster_name = var.cluster_name
  subnet_ids   = module.vpc.private_subnets

  # Required attributes
  ssh_key_name = var.ssh_key_name
  node_sg_id   = module.compute.node_sg_id
}

module "ecr" {
  source = "./modules/ecr"
}

module "secrets" {
  source = "./modules/secrets"

  db_username = var.db_username
  db_password = var.db_password
  api_key     = var.api_key
}

module "rds" {
  source                 = "./modules/rds"
  db_name                = var.db_name
  db_username            = var.db_username
  db_password_secret_arn = module.secrets.db_password_secret_arn
  db_password_key        = "db_password"
  vpc_id                 = module.vpc.vpc_id
  eks_node_group_sg      = module.eks.cluster_security_group_id
  private_subnets        = module.vpc.private_subnets
}

module "iam" {
  source = "./modules/iam"

  #Pass OIDC provider details from EKS outputs
  eks_oidc_provider_arn  = module.eks.eks_oidc_provider_arn
  eks_oidc_provider_url  = module.eks.eks_oidc_provider_url

  #Pass secrets ARNs from the Secrets module
  db_username_secret_arn = module.secrets.db_username_secret_arn
  db_password_secret_arn = module.secrets.db_password_secret_arn
  api_key_secret_arn     = module.secrets.api_key_secret_arn

  #Pass Jenkins role name from Compute module
  jenkins_role_name      = module.compute.jenkins_role_name
}


module "kubernetes" {
  source = "./modules/kubernetes"

  cluster_name     = module.eks.cluster_name
  cluster_endpoint = module.eks.cluster_endpoint
  cluster_ca       = module.eks.cluster_ca
  cluster_token    = data.aws_eks_cluster_auth.cluster.token

  region                 = var.region
  vpc_id                 = module.vpc.vpc_id
  irsa_role_arn          = module.iam.secrets_role_arn  
  db_username_secret_arn = module.secrets.db_username_secret_arn
  db_password_secret_arn = module.secrets.db_password_secret_arn
  api_key_secret_arn     = module.secrets.api_key_secret_arn
  alb_role_arn           = module.iam.alb_controller_role_arn

  jenkins_role_arn = module.compute.jenkins_role_arn

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }
}

module "monitoring" {
  source          = "./modules/monitoring"
  cluster_name    = module.eks.cluster_name
  node_group_name = "${module.eks.cluster_name}-workers"
  region          = "ap-south-1"

  log_group_name      = "/aws/eks/${module.eks.cluster_name}"
  cpu_alarm_threshold = 75

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }
}