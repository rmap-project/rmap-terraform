provider "aws" {
    region = "us-east-1"
    profile = "jhuadmin"
}

terraform {
    backend "s3" {
        bucket = "msel-ops-terraform-statefiles"
        key = "applications/rmap"
        region = "us-east-1"
        profile = "jhuadmin"        
    }
}
data "terraform_remote_state" "shared" {
    backend = "s3"
    config {
        profile = "jhuadmin"
        bucket = "msel-ops-terraform-statefiles"
        key = "applications/rmap-shared"
        region = "us-east-1"

    }
}

data "aws_route53_zone" "orgzone" {
    name = "rmap-hub.org"
    private_zone = false
}

data "aws_route53_zone" "comzone" {
    name = "rmap-hub.com"
    private_zone = false
}

data "aws_route53_zone" "netzone" {
    name = "rmap-hub.net"
    private_zone = false
}