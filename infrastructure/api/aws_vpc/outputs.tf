output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.this.*.id
}

output "public_subnet_ids" {
  description = "ID's of the Public subnets"
  value       = aws_subnet.public.*.id
}

output "private_subnet_ids" {
  description = "ID's of the Private subnets"
  value       = aws_subnet.private.*.id
}
