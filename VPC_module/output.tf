output "vpc_id" {
    value = "${aws_vpc.vpc.id}"
}

output "name_tag" {
    value = "${var.name_tag}"
}