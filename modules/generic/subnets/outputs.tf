output "subnet_ids" {
  value = aws_subnet.subnets.*.id
}

output "subnet_cidrs" {
  value = var.cidrs
}

output "subnets" {
  value = aws_subnet.subnets
}
