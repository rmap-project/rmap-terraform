resource "aws_eip" "nat" {
    vpc = true
    tags {
        Name = "rmap-nat"
        Environment = "shared"
        Project = "RMAP"
    }
}

resource "aws_nat_gateway" "nat" {
    subnet_id = "${aws_subnet.shared1.id}"
    allocation_id = "${aws_eip.nat.id}"
    tags {
        Name = "rmap-nat"
        Project = "RMAP"
        Environment = "shared"
    }
}