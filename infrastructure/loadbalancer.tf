resource "aws_security_group" "lb" { 
    name = "rmap_${terraform.workspace}_lb"
    description = "Load Balancer security group for rmap-${terraform.workspace}"
    vpc_id = "${data.terraform_remote_state.shared.vpc_id}"

    ingress {
        to_port = 80
        from_port = 80
        cidr_blocks = ["0.0.0.0/0"]
        protocol = "tcp"
    }

    ingress {
        to_port = 443
        from_port = 443
        cidr_blocks = ["0.0.0.0/0"]
        protocol = "tcp"
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    tags {
        Name = "rmap_${terraform.workspace}_lb"
        Project = "RMAP"
        Environment = "${terraform.workspace}"
    }
}

resource "aws_lb" "default" {
    name = "rmap${terraform.workspace}"
    internal = false
    load_balancer_type = "application"
    security_groups = ["${aws_security_group.lb.id}"]
    subnets = ["${data.terraform_remote_state.shared.subnet_shared1_id}", "${data.terraform_remote_state.shared.subnet_shared2_id}"]
    enable_deletion_protection = false

    tags = {
        Environment = "${terraform.workspace}"
        Project = "RMAP"
        Name = "rmap${terraform.workspace}"
    }
}

resource "aws_lb_target_group" "appserver" {
    name = "rmap-${terraform.workspace}-lb-appserver"
    port = 80
    protocol = "HTTP"
    vpc_id = "${data.terraform_remote_state.shared.vpc_id}"
}

resource "aws_lb_listener" "appserver443" {
   load_balancer_arn = "${aws_lb.default.arn}"
   port = "443"
   protocol = "HTTPS"
   ssl_policy = "ELBSecurityPolicy-2016-08"
   certificate_arn = "${aws_acm_certificate.cert.arn}"

   default_action {
       type = "forward"
       target_group_arn = "${aws_lb_target_group.appserver.arn}"
   }
}

resource "aws_lb_listener" "appserver80" {
   load_balancer_arn = "${aws_lb.default.arn}"
   port = "80"
   protocol = "HTTP"

   default_action {
       type = "redirect"
       
       redirect {
           port = "443"
           protocol = "HTTPS"
           status_code = "HTTP_301"
       }
   }
}

resource "aws_lb_target_group_attachment" "appserver" {
    target_group_arn = "${aws_lb_target_group.appserver.arn}"
    target_id = "${aws_instance.appserver.id}"
    port = 80
}

resource "aws_route53_record" "orgzonelb" {
    zone_id = "${data.aws_route53_zone.orgzone.id}"
    name = "${terraform.workspace}"
    type = "CNAME"
    ttl = "60"
    records = [ "${aws_lb.default.dns_name}"]
}