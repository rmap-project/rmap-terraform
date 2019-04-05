resource "aws_db_subnet_group" "default" {
    name = "rmap-${terraform.workspace}"
    subnet_ids = [ "${aws_subnet.subnet1.id}", "${aws_subnet.subnet2.id}"]
    description = "RMAP ${terraform.workspace} database subnet group"
    tags {
        Name = "rmap-${terraform.workspace} db"
        Environemnt = "${terraform.workspace}"
        Project = "RMAP"
    }
}

resource "random_string" "mariadb_password" {
    length = 16
    special = false
}

resource "aws_security_group" "mariadb" {
    name = "rmap_${terraform.workspace}_mariadb"
    description = "MariaDB SecurityGroup for rmap-${terraform.workspace}"
    vpc_id = "${data.terraform_remote_state.shared.vpc_id}"

    ingress {
        to_port = 3306
        from_port = 3306
        protocol = "tcp"
        security_groups = [ "${data.terraform_remote_state.shared.ops_security_group}",  "${data.terraform_remote_state.shared.allow_ops_security_group}"]
    }
}

resource "aws_db_instance" "appserver" {
    allocated_storage       = 100
    storage_type            = "io1"
    availability_zone       = "us-east-1c"
    iops = 1000

    name = "rmap"

    instance_class = "db.t2.small"
    username = "rmap"
    password = "${random_string.mariadb_password.result}"

    engine = "mariadb"
    engine_version = "10.2.21"

    db_subnet_group_name = "${aws_db_subnet_group.default.id}"
    skip_final_snapshot = true

    identifier = "rmap-${terraform.workspace}"
    vpc_security_group_ids = ["${aws_security_group.mariadb.id}"]

    tags {
        Name = "rmap-${terraform.workspace}"
        Environment = "${terraform.workspace}"
        Project = "RMAP"
    }

    # provisioner "file" {
    #     source = "appserver/sql"
    # }

    provisioner "file" {
        source = "configs/createTables.sql"
        destination = "/tmp/createTables.sql"

        connection {
            type = "ssh"
            host = "ops.rmap-hub.org"
            user = "ec2-user"
            agent = "true"
        }
    }

    provisioner "remote-exec" {
        inline = [
            "touch ~/.my-${terraform.workspace}.ini",
            "echo '[client]' > ~/.my-${terraform.workspace}.ini",
            "echo 'user=rmap' >> ~/.my-${terraform.workspace}.ini",
            "echo 'host=${aws_db_instance.appserver.address}' >> ~/.my-${terraform.workspace}.ini",
            "echo 'password=${random_string.mariadb_password.result}' >> ~/.my-${terraform.workspace}.ini",
            "mysql --defaults-file=~/.my-${terraform.workspace}.ini -D rmap -e 'source /tmp/createTables.sql'"
        ]

        connection {
            type = "ssh"
            host = "ops.rmap-hub.org"
            user = "ec2-user"
            agent = true
        }
    }

    provisioner "remote-exec" {
        inline = [
            "echo 'rmap:${random_string.mariadb_password.result}' > ~/mariadb.txt"
        ]

        connection {
            type = "ssh"
            host = "appserver.${terraform.workspace}.rmap-hub.org"
            user = "ec2-user"
            agent = true

            bastion_host = "ops.rmap-hub.org"
            bastion_user = "ec2-user"
        }
    }
}

resource "aws_route53_record" "appserver_db" {
    zone_id = "${data.aws_route53_zone.orgzone.id}"
    name = "mariadb.${terraform.workspace}.rmap-hub.org"
    type = "CNAME"
    ttl = "10"

    records = [ "${aws_db_instance.appserver.address}"]
}

output "database_user" {
    value = "rmap"
}

output "database_password" {
    value = "${random_string.mariadb_password.result}"
}