resource "aws_vpc" "default" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true

    tags {
        Name = "RMAP Infrastructure"
        Project = "RMAP"
        Environment = "shared"
    }
}

resource "aws_internet_gateway" "default" {
    vpc_id = "${aws_vpc.default.id}"
    tags {
        Name = "rmap-internet"
        Environment = "shared"
        Project = "RMAP"
    }
}
resource "aws_subnet" "shared1" {
    vpc_id = "${aws_vpc.default.id}"
    cidr_block = "10.0.0.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
    
    tags {
        Name = "rmap-shared-1"
        Environment = "shared"
        Project = "RMAP"
    }
}

resource "aws_subnet" "shared2" {
    vpc_id = "${aws_vpc.default.id}"
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1c"
    map_public_ip_on_launch = true

    tags {
        Name = "rmap-shared-2"
        Environment = "shared"
        Project = "RMAP"
    }
}

resource "aws_route_table" "nat" {
    vpc_id = "${aws_vpc.default.id}"
    tags {
        Name = "rmap-nat"
        Project = "RMAP"
        Environment = "shared"
    }
}

resource "aws_route" "default" {
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
    route_table_id = "${aws_vpc.default.default_route_table_id}"
}

resource "aws_route" "nat" {
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat.id}"
    route_table_id = "${aws_route_table.nat.id}"
}

resource "aws_security_group" "allow_egress" {
    name = "rmap_allow_outbound"
    description = "Allow outbound traffic"
    vpc_id = "${aws_vpc.default.id}"

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
        Name = "rmap_allow_outbound"
        Project = "RMAP"
        Environment = "shared"
    }
}

resource "aws_route_table_association" "shared1" {
    subnet_id = "${aws_subnet.shared1.id}"
    route_table_id = "${aws_vpc.default.default_route_table_id}"
}

resource "aws_route_table_association" "shared2" {
    subnet_id = "${aws_subnet.shared2.id}"
    route_table_id = "${aws_vpc.default.default_route_table_id}"
}

output "vpc_id" {
    value = "${aws_vpc.default.id}"
}

output "nat_route_table" {
    value = "${aws_route_table.nat.id}"
}

output "allow_egress_security_group" {
    value = "${aws_security_group.allow_egress.id}"
}

output "subnet_shared1_id" {
    value = "${aws_subnet.shared1.id}"
}

output "subnet_shared2_id" {
    value = "${aws_subnet.shared2.id}"
}