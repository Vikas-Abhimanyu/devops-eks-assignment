data "terraform_remote_state" "eks" {
  backend = "s3"

  config = {
    bucket = "my-terraform-state-bucket-17-03"
    key    = "03-eks/terraform.tfstate"
    region = "ap-south-1"
  }
}