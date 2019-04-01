variable "zookeeper_url" {
    type = "string"
    default = "http://www.gtlib.gatech.edu/pub/apache/zookeeper/zookeeper-3.4.13/zookeeper-3.4.13.tar.gz"
}

variable "kafka_url" {
    type = "string"
    default = "ftp://apache.cs.utah.edu/apache.org/kafka/2.2.0/kafka_2.12-2.2.0.tgz"
}

variable "subnet1_cidr" {
    type = "map"
    default = {
        "ops" = "10.0.10.0/24",
        "test" = "10.0.20.0/24",
        "dev" = "10.0.30.0/24",
        "demo" = "10.0.40.0/24",
        "production" = "10.0.50.0/24"
    }
}

variable "subnet2_cidr" {
    type = "map"
    default = {
        "ops" = "10.0.11.0/24",
        "test" = "10.0.21.0/24",
        "dev" = "10.0.31.0/24",
        "demo" = "10.0.41.0/24",
        "production" = "10.0.51.0/24"
    }
}