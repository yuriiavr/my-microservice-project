output "vpc_id" {
  description = "ID створеної VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "CIDR-блок VPC."
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "ID публічних підмереж."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "ID приватних підмереж."
  value       = aws_subnet.private[*].id
}

output "internet_gateway_id" {
  description = "ID Internet Gateway."
  value       = aws_internet_gateway.this.id
}

output "nat_gateway_id" {
  description = "ID NAT Gateway."
  value       = aws_nat_gateway.this.id
}
