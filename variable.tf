variable "profile" {
    type = string
    description = "provider profile name"
}

variable "cidr"{
    type=string
    description = "vpc cidr"
}

variable "region" {
  type=string
  description = "provider region"
}

variable "azs" {
 type        = list(string)
 description = "Availability Zones"
 //default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnet_cidrs" {
 type        = list(string)
 description = "Public Subnet CIDR values"
 //default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
 
variable "private_subnet_cidrs" {
 type        = list(string)
 description = "Private Subnet CIDR values"
 //default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "ami_id"{
  type= string
  description = "ami id"
}

variable "key_pair"{
  tyoe=string
  default = "packer_63f4f1f7-0b96-e39c-f393-af095e05e58b"
}
