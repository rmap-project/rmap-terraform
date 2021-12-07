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