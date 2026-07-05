output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]
}

output "private_app_subnet_ids" {
  value = [
    aws_subnet.private_app_1.id,
    aws_subnet.private_app_2.id
  ]
}

output "private_db_subnet_ids" {
  value = [
    aws_subnet.private_db_1.id,
    aws_subnet.private_db_2.id
  ]
}
output "public_route_table_id" {
  value = aws_route_table.public.id
}

output "private_app_route_table_id" {
  value = aws_route_table.private_app.id
}

output "private_db_route_table_id" {
  value = aws_route_table.private_db.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.this.id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.this.id
}