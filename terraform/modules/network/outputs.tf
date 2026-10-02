output "vpc_id" {
  description = "ID du VPC"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "IDs des sous-réseaux publics"
  value       = aws_subnet.public[*].id
}

output "app_subnet_ids" {
  description = "IDs des sous-réseaux privés applicatifs"
  value       = aws_subnet.app[*].id
}

output "data_subnet_ids" {
  description = "IDs des sous-réseaux privés de données"
  value       = aws_subnet.data[*].id
}

output "alb_sg_id" {
  description = "ID du security group de l'ALB"
  value       = aws_security_group.alb.id
}

output "app_sg_id" {
  description = "ID du security group des instances applicatives"
  value       = aws_security_group.app.id
}

output "db_sg_id" {
  description = "ID du security group de la base de données"
  value       = aws_security_group.db.id
}

output "nat_public_ip" {
  description = "IP publique de la NAT Gateway"
  value       = aws_eip.nat.public_ip
}
