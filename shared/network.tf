resource "aws_vpc" "default" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true

    tags {
        Name = "RMAP Infrastructure"
        Project = "RMAP"
        Environment = "Shared"
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
        Environment = "Shared"
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