resource "aws_security_group" "zookeeper" {
    name = "rmap_${terraform.workspace}_zookeeper"
    vpc_id = "${data.terraform_remote_state.shared.vpc_id}"

    ingress {
        from_port = 2181
        to_port = 2181
        protocol = "tcp"

        security_groups = [ "${aws_security_group.appserver80.id}"]
    }

    ingress {
        from_port = 9092
        to_port = 9092
        protocol = "tcp"

        security_groups = [ "${aws_security_group.appserver80.id}"]
    }

    tags {
        Name = "rmap_${terraform.workspace}_zookeeper"
        Project = "RMAP"
        Environment = "${terraform.workspace}"
    }
}
resource "aws_instance" "zk" {
    count = 1
    ami = "${data.terraform_remote_state.shared.amz_ami_id}"
    instance_type = "t2.small"
    subnet_id = "${aws_subnet.subnet2.id}"

    vpc_security_group_ids = ["${aws_security_group.zookeeper.id}", "${data.terraform_remote_state.shared.allow_ops_security_group}", "${data.terraform_remote_state.shared.allow_egress_security_group}"]
    key_name = "operations"

    tags {
        Name = "rmap_${terraform.workspace}_zookeeper"
        Project = "RMAP"
        Environment = "${terraform.workspace}"
    }

    ebs_block_device {
        device_name = "/dev/sdg"
        volume_size = 20
        volume_type = "gp2"
        delete_on_termination = false
    }
    provisioner "remote-exec" {
        inline = [
            "sudo yum install -y java-1.8.0-openjdk-headless curl",
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

resource "aws_route53_record" "zk" {
    zone_id = "${data.aws_route53_zone.orgzone.id}"
    name = "zk.${terraform.workspace}"
    type = "A"
    ttl = "10"

    records = [ "${aws_instance.zk.private_ip}"]
}

output "zk_ips" {
    value = "${aws_instance.zk.*.private_ip}"
}