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
    availability_zones = "us-east-1a"
    tags {
        Name = "rmap-shared-1"
        Environment = "shared"
        Project = "RMAP"
    }
}

resource "aws_subnet" "subnet2" {
    vpc_id = "${aws_vpc.default.id}"
    cidr_block = "10.0.1.0/24"
    availability_zones = "us-east-1c"

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
    route_table_id = "${aws_vpc.default.defatul_route_table_id}"
}

resource "aws_route" "nat" {
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat.id}"
    route_table_id = "${aws_route.nat.id}"
}