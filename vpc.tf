resource "aws_vpc" "Guangyu" {
    cidr_block = var.cidr//"10.0.0.0/16"
    enable_dns_hostnames = true
    tags ={
        Name = "terraform_aws_vpc"
    }
}