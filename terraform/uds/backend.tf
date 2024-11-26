terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    region  = "us-west-1"
    bucket  = "homelab-lobster-terraform-state"
    key     = "uds.tfstate"
    profile = ""
    encrypt = "true"

    dynamodb_table = "homelab-lobster-terraform-state-lock"
  }
}

