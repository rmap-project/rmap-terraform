variable "ssh_key_path" {
    type = "string"
    description = "Full path to your SSH key used by the servers"
    default = "~/.ssh/aws-us-east1-operations.pem"
}