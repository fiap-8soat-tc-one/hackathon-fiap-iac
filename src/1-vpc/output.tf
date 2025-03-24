output "id" {
  value = aws_vpc.main.id
}

output "public_subnet_a" {
  value = aws_subnet.public_subnet_a.id
}

output "public_subnet_b" {
  value = aws_subnet.public_subnet_b.id
}

output "public_subnet_ids" {
  value = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
}

output "cidr_block" {
  value = aws_vpc.main.cidr_block
}

output "public_subnet_a_cidr_block" {
  value = aws_subnet.public_subnet_a.cidr_block
}

output "public_subnet_b_cidr_block" {
  value = aws_subnet.public_subnet_b.cidr_block
}

output "public_subnet_cidrs" {
  value = [
    aws_subnet.public_subnet_a.cidr_block,
    aws_subnet.public_subnet_b.cidr_block
  ]
}