data "aws_route53_zone" "orgzone" {
    name = "rmap-hub.org"
    private = false
}

data "aws_route53_zone" "comzone" {
    name = "rmap-hub.com"
    private = false
}

data "aws_route53_zone" "netzone" {
    name = "rmap-hub.net"
    private = false
}