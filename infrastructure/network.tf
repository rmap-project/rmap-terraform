resource "aws_subnet" "subnet1" {
    vpc_id = "${data.terraform_remote_state.shared.vpc_id}"
    cidr_block = "${lookup(var.subnet1_cidr, terraform.workspace)}"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = false

    tags {
        Name = "rmap-${terraform.workspace}-1"
        Environment = "${terraform.workspace}"
        Project = "RMAP"
    }
}

resource "aws_subnet" "subnet2" {
    vpc_id = "${data.terraform_remote_state.shared.vpc_id}"
    cidr_block = "${lookup(var.subnet2_cidr, terraform.workspace)}"
    availability_zone = "us-east-1c"
    map_public_ip_on_launch = false

    tags {
        Name = "rmap-${terraform.workspace}-2"
        Environment = "${terraform.workspace}"
        Project = "RMAP"
    }
}

resource "aws_route_table_association" "subnet1" {
    subnet_id = "${aws_subnet.subnet1.id}"
    route_table_id = "${data.terraform_remote_state.shared.nat_route_table}"
}

resource "aws_route_table_association" "subnet2" {
    subnet_id = "${aws_subnet.subnet2.id}"
    route_table_id = "${data.terraform_remote_state.shared.nat_route_table}"
}