output "vpc_id" {
  description = "ID du VPC"
  value       = module.network.vpc_id
}

output "nat_public_ip" {
  description = "IP publique de sortie (NAT Gateway)"
  value       = module.network.nat_public_ip
}

output "db_endpoint" {
  description = "Adresse de l'instance RDS"
  value       = module.data.db_address
}

output "db_secret_arn" {
  description = "ARN du secret Secrets Manager contenant le mot de passe RDS"
  value       = module.data.db_secret_arn
}

output "assets_bucket" {
  description = "Nom du bucket S3 applicatif"
  value       = module.data.bucket_name
}
