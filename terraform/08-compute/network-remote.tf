data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "my-terraform-state-bucket-17-03"
    key    = "02-network/terraform.tfstate"
    region = "ap-south-1"
  }
}