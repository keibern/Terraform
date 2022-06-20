variable "name_tag" {
    type    = string
    default = ""
}

variable "vpc_id" {
    type    = string
    default = ""
}

variable "name_tag_sg" {
    type    = string
    default = ""
}

variable "SecurityGroup_ingress" {
  type        = list(map(string))
  default     = []
}

variable "SecurityGroup_egress" {
  type        = list(map(string))
  default     = []
}