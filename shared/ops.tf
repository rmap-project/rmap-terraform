data "aws_ami" "amz_linux" {
    most_recent = true
    owners = ["amazon"]

    filter {
        name = "name"
        values = ["amzn2-ami-hvm*-x86_64-gp2"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

resource "aws_security_group" "ops" {
    name = "rmap_ops_allow_ssh"
    description = "Allows SSH to RMAP Ops Server"
    vpc_id = "${aws_vpc.default.id}"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"

        cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
        Name = "rmap_ops_allow_ssh"
        Project = "RMAP"
        Environment = "shared"
    }    
}

resource "aws_security_group" "allow_ops" {
    name = "rmap_allow_ops_in"
    description = "Allow full access from Ops server"
    vpc_id = "${aws_vpc.default.id}"

    ingress {
        from_port = 0
        to_port = 0
        protocol = -1
        security_groups = [ "${aws_security_group.ops.id}"]
    }

    tags {
        Name = "rmap_allow_ops_in"
        Project = "RMAP"
        Environment = "shared"
    }
}

resource "aws_iam_role" "ops_server" {
    name = "rmap_ops_role"
    path = "/"

    assume_role_policy = <<EOF
{  
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "ops_ssm" {
    name = "rmap_ops_ssm_access"
    role = "${aws_iam_role.ops_server.id}"

    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParametersByPath",
                "ssm:GetParameters",
                "ssm:GetParameter"
            ],
            "Resource": "arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:parameter/rmap/*"
        }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "ops" {
    name = "rmap_ops_instance_profile",
    role = "${aws_iam_role.ops_server.id}"
}

resource "aws_instance" "ops" {
    ami = "${data.aws_ami.amz_linux.id}"
    instance_type = "t2.small"
    subnet_id = "${aws_subnet.shared1.id}"

    vpc_security_group_ids = ["${aws_security_group.allow_egress.id}", "${aws_security_group.ops.id}"]
    key_name = "operations"

    iam_instance_profile = "${aws_iam_instance_profile.ops.id}"

    tags {
        Name = "rmap-ops-server"
        Project = "RMAP"
        Environment = "shared"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo yum -y install jq mysql",
            "aws ssm get-parameter --with-decryption --name /rmap/shared/github_key --region us-east-1 | jq -re '.Parameter.Value' > ~/.ssh/github.pem",
            "chmod 600 .ssh/*",
            "touch ~/.configured"
        ]   
        connection {
            type = "ssh"
            agent = true
            user = "ec2-user"
            # private_key = "${var.ssh_key_path}"            
        }
    }
}

resource "aws_route53_record" "ops" {
    zone_id = "${data.aws_route53_zone.orgzone.id}"
    name = "ops"
    type = "CNAME"
    ttl = "10"

    records = [ "${aws_instance.ops.public_dns}" ]
}

output "ops_security_group" {
    value = "${aws_security_group.ops.id}"
}

output "allow_ops_security_group" {
    value = "${aws_security_group.allow_ops.id}"
}

output "amz_ami_id" {
    value = "${data.aws_ami.amz_linux.id}"
}