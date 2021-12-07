resource "aws_route53_record" "orgzone" {
    name = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
    type = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_type}"

    zone_id = "${data.aws_route53_zone.orgzone.zone_id}"
    records = [ "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
    ttl = 60
}

resource "aws_route53_record" "comzone" {
    name = "${aws_acm_certificate.cert.domain_validation_options.1.resource_record_name}"
    type = "${aws_acm_certificate.cert.domain_validation_options.1.resource_record_type}"

    zone_id = "${data.aws_route53_zone.comzone.zone_id}"
    records = [ "${aws_acm_certificate.cert.domain_validation_options.1.resource_record_value}"]
    ttl = 60     
}

resource "aws_route53_record" "netzone" {
    name = "${aws_acm_certificate.cert.domain_validation_options.2.resource_record_name}"
    type = "${aws_acm_certificate.cert.domain_validation_options.2.resource_record_type}"

    zone_id = "${data.aws_route53_zone.netzone.zone_id}"
    records = [ "${aws_acm_certificate.cert.domain_validation_options.2.resource_record_value}"]
    ttl = 60     
}

resource "aws_acm_certificate_validation" "cert" {
    certificate_arn = "${aws_acm_certificate.cert.arn}"

    validation_record_fqdns = [
        "${aws_route53_record.orgzone.fqdn}",
        "${aws_route53_record.comzone.fqdn}",
        "${aws_route53_record.netzone.fqdn}"
    ]

}

resource "aws_acm_certificate" "cert" {
    domain_name = "${terraform.workspace}.rmap-hub.org"
    subject_alternative_names = [ "${terraform.workspace}.rmap-hub.com", "${terraform.workspace}.rmap-hub.net"]
    validation_method = "DNS"

    tags {
        Project = "RMAP"
        Environment = "${terraform.workspace}"
        Name = "rmap-${terraform.workspace}"
    }
}