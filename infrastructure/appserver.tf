resource "aws_instance" "appserver" {
    count = 1
    ami = "${data.terraform_remote_state.shared.amz_ami_id}"
    instance_type = "t2.small"
    subnet_id = "${aws_subnet.subnet2.id}"

    vpc_security_group_ids = [ "${data.terraform_remote_state.shared.allow_ops_security_group}", "${data.terraform_remote_state.shared.allow_egress_security_group}"]
    key_name = "operations"

    tags {
        Name = "rmap_${terraform.workspace}_appserver"
        Project = "RMAP"
        Environment = "${terraform.workspace}"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo yum install -y java-1.8.0-openjdk-headless curl"
        ]

        connection {
            type = "ssh"
            agent = true
            user = "ec2-user"

            bastion_host = "ops.rmap-hub.org"
            bastion_user = "ec2-user"
        }
    }
}

resource "aws_route53_record" "appserver" {
    zone_id = "${data.aws_route53_zone.orgzone.id}"
    name = "appserver.${terraform.workspace}"
    type = "A"
    ttl = "10"

    records = ["${aws_instance.appserver.private_ip}"]
}

output "appserver_ips" {
    value = "${aws_instance.appserver.*.private_ip}"
}

