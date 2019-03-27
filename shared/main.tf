provider "aws" {
    region = "us-east-1"
    profile = "jhuadmin"
}

terraform {
    backend "s3" {
        bucket = "msel-ops-terraform-statefiles"
        key = "applications/rmap-shared"
        region = "us-east-1"
        profile = "jhuadmin"
    }
}

data "aws_caller_identity" "current" {}