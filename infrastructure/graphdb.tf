resource "aws_security_group" "graphdb" {
    name = "rmap_${terraform.workspace}_graphdb"
    vpc_id = "${data.terraform_remote_state.shared.vpc_id}"

    ingress {
        from_port = 7200
        to_port = 7200
        security_groups = [ "${data.terraform_remote_state.shared.allow_ops_security_group}", "${aws_security_group.appserver80.id}"]
        protocol = "tcp"
    }

    tags {
        Name = "rmap_${terraform.workspace}_graphdb"
        Project = "RMAP"
        Environment = "${terraform.workspace}"
    }
}

resource "aws_instance" "graphdb" {
    count = 1
    ami = "${data.terraform_remote_state.shared.amz_ami_id}"
    instance_type = "t2.xlarge"
    subnet_id = "${aws_subnet.subnet1.id}"

    vpc_security_group_ids = [ "${aws_security_group.graphdb.id}", "${data.terraform_remote_state.shared.allow_ops_security_group}", "${data.terraform_remote_state.shared.allow_egress_security_group}"]
    key_name = "operations"

    tags {
        Name = "rmap_${terraform.workspace}_graphdb"
        Project = "RMAP"
        Environment = "${terraform.workspace}"
    }

    ebs_block_device {
        device_name = "/dev/xvdb"
        volume_size = 20
        volume_type = "gp2"
        delete_on_termination = false
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

resource "aws_route53_record" "graphdb" {
    zone_id = "${data.aws_route53_zone.orgzone.id}"
    name = "graphdb.${terraform.workspace}"
    type = "A"
    ttl = "10"

    records = [ "${aws_instance.graphdb.private_ip}"]
}

output "graphdb_ips" {
    value = "${aws_instance.graphdb.*.private_ip}"
}