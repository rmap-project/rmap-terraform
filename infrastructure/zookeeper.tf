resource "aws_instance" "zk" {
    count = 1
    ami = "${data.terraform_remote_state.shared.amz_ami_id}"
    instance_type = "t2.small"
    subnet_id = "${aws_subnet.subnet2.id}"

    vpc_security_group_ids = ["${data.terraform_remote_state.shared.allow_ops_security_group}", "${data.terraform_remote_state.shared.allow_egress_security_group}"]
    key_name = "operations"

    tags {
        Name = "rmap_${terraform.workspace}_zookeeper"
        Project = "RMAP"
        Environment = "${terraform.workspace}"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo yum install -y java-1.8.0-openjdk-headless curl",
            "curl -sSL -o /tmp/zookeeper.tar.gz ${var.zookeeper_url}",
            "sudo mkdir /opt/zookeeper",
            "sudo tar --strip-components=1 -zxvf /tmp/zookeeper.tar.gz -C /opt/zookeeper",
            "curl -sSL -o /tmp/kafka.tgz ${var.kafka_url}",
            "sudo mkdir /opt/kafka",
            "sudo tar --strip-components=1 -zxvf /tmp/kafka.tgz -C /opt/kafka",
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