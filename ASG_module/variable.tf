variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  type        = string
  default     = "0.0.0.0/0"
}

variable "vpc_tags" {
  description = "Additional tags for the VPC"
  type        = map(string)
  default     = {}
}