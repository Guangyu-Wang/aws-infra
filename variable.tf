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
  type=string
  default = "aws-demo"//"aws-dev"
}

 variable "db_username"{
  type=string
  default="csye6225"
 }

 variable "db_password"{
  type=string
  default="60446201Wgy"
 }

 variable "db_name"{
  type=string
  default = "cloud"
 }

 variable "zone_id" {
   type =string

   default = "Z0850360CZACY5TUTPWS"//"Z09075551AWE1P66OZOPX"
 }

 variable "certificate_arn" {
   type=string
   default = "arn:aws:acm:us-east-1:492677447136:certificate/f188d0fc-4c2c-4242-b758-62e09da826c2"//"arn:aws:acm:us-east-1:317988945521:certificate/6354afd7-7cfe-49a1-b9b2-2c946df005b3"

 }