// Credentials
variable "awsprofile" {}

variable "aws_key_name" {
  default = "demo"
}

variable "aws_region" {
  description = "EC2 Region for all VPC's"
  default     = "us-east-1"
}

variable "ami" {
  description = "AMI"

  default = {
    //us-east-2 = "ami-0125a7e5b2489477a" # ubuntu 18.04 LTS
    us-east-1 = "ami-0b86cfbff176b7d3a" # ubuntu 18.04 LTS
  }
}

variable "main_vpc_cidr" {
  description = "CIDR for the main VPC"
  default     = "172.20.0.0/16"
}

variable "main_public_subnet_cidr" {
  description = "CIDR for the Public Subnet"
  default     = "172.20.0.0/24"
}

variable "main_private_subnet_cidr" {
  description = "CIDR for the Private Subnet"
  default     = "172.20.1.0/24"
}

variable "legacy_vpc_cidr" {
  description = "CIDR for the legacy VPC"
  default     = "10.0.0.0/16"
}

variable "legacy_public_subnet_cidr" {
  description = "CIDR for the Public Subnet"
  default     = "10.0.0.0/24"
}

variable "legacy_private_subnet_cidr" {
  description = "CIDR for the Private Subnet"
  default     = "10.0.1.0/24"
}

# variable "app1_vpc_cidr" {
#   description = "CIDR for the app1 VPC"
#   default     = "10.1.0.0/16"
# }
#
# variable "app1_public_subnet_cidr" {
#   description = "CIDR for the Public Subnet"
#   default     = "10.1.0.0/24"
# }
#
# variable "app1_private_subnet_cidr" {
#   description = "CIDR for the Private Subnet"
#   default     = "10.1.1.0/24"
# }
#
# variable "app2_vpc_cidr" {
#   description = "CIDR for the app2 VPC"
#   default     = "172.18.0.0/16"
# }
#
# variable "app2_public_subnet_cidr" {
#   description = "CIDR for the Public Subnet"
#   default     = "172.18.0.0/24"
# }
#
# variable "app2_private_subnet_cidr" {
#   description = "CIDR for the Private Subnet"
#   default     = "172.18.1.0/24"
# }
#
# variable "app3_vpc_cidr" {
#   description = "CIDR for the app3 VPC"
#   default     = "172.16.0.0/16"
# }
#
# variable "app3_public_subnet_cidr" {
#   description = "CIDR for the Public Subnet"
#   default     = "172.16.0.0/24"
# }
#
# variable "app3_private_subnet_cidr" {
#   description = "CIDR for the Private Subnet"
#   default     = "172.16.1.0/24"
# }

