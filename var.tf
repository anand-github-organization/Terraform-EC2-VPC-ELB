variable "region" {
  type    = string
  default = "us-east-1"
}
variable "ami_id" {
  type = map(any)
  default = {
    us-east-1 = "ami-0022f774911c1d690"
    us-east-2 = "ami-0fa49cc9dc8d62c84"

  }
}
variable "instance_type" {
  type    = string
  default = "t2.micro"
}
variable "key_name" {
  type    = string
  default = "Anand_key"
}

variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  type        = string
  default     = "10.0.0.0/16"
}
variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC"
  type        = string
  default     = "default"
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "enable_classiclink" {
  description = "Should be true to enable ClassicLink for the VPC. Only valid in regions and accounts that support EC2 Classic."
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = string
  default     = "vpc-custom-demo"
}
variable "access_key" {
  type = string
  description = "aws access_key"
  default = ""
}
variable "secret_key" {
  type = string
  description = "aws access_key"
  default = ""
}

