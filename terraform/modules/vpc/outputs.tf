output "vpc_id" {
  description = "VPC ID."
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block."
  value       = aws_vpc.this.cidr_block
}

output "internet_gateway_id" {
  description = "Internet Gateway ID."
  value       = aws_internet_gateway.this.id
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs."
  value       = aws_nat_gateway.this[*].id
}

output "nat_eip_ids" {
  description = "Elastic IP allocation IDs for NAT gateways."
  value       = aws_eip.nat[*].id
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = aws_subnet.public[*].id
}

output "private_app_subnet_ids" {
  description = "Private application subnet IDs."
  value       = aws_subnet.private_app[*].id
}

output "private_db_subnet_ids" {
  description = "Private database subnet IDs."
  value       = aws_subnet.private_db[*].id
}

output "public_route_table_id" {
  description = "Public route table ID."
  value       = aws_route_table.public.id
}

output "private_app_route_table_ids" {
  description = "Private application route table IDs."
  value       = aws_route_table.private_app[*].id
}

output "private_db_route_table_ids" {
  description = "Private database route table IDs."
  value       = aws_route_table.private_db[*].id
}
