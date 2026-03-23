output "cluster_name" {
  value = module.eks.cluster_name
}

output "backend_ecr" {
  value = module.ecr.backend_repo
}

output "frontend_ecr" {
  value = module.ecr.frontend_repo
}

output "rds_endpoint" {
  value = module.rds.endpoint
}
