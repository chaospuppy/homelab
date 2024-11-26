provider "aws" {
  region = var.region
}

module "terraform_state_backend" {
  source = "cloudposse/tfstate-backend/aws"
  # Cloud Posse recommends pinning every module to a specific version
  version       = "1.5.0"
  namespace     = "homelab"
  stage         = "lobster"
  name          = "terraform"
  attributes    = ["state"]
  arn_format    = "arn:aws"
  force_destroy = false
}

