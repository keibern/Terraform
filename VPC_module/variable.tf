
variable "name_tag" {
    type    = string
    default = ""
}

variable "vpc_cidr" {
    type    = string
    default = "0.0.0.0/0"
}

variable "subnet_public_az" {
    type    = list(string)
    default = []
}

variable "subnet_private_az" {
    type    = list(string)
    default = []
}

variable "subnet_public_cidr" {
    type    = list(string)
    default = []
}

variable "subnet_private_cidr" {
    type = list(string)
    default = []
}

variable "create_nat_gateway" {
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  type        = bool
  default     = false
}

variable "nogate_subnet_private" {
  type        = bool
  default     = false
}