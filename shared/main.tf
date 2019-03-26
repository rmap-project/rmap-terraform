provider "aws" {
    region = "us-east-1"
    profile = "rmap-deploy"
}

terraform {
    backend "s3" {
        bucket = "msel-ops-terraform-statefiles"
        key = "applications/rmap-shared"
        region = "us-east-1"
        profile = "jhuadmin"
    }
}