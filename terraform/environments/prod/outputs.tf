output "vpc_id" {
  description = "ID du VPC"
  value       = module.network.vpc_id
}

output "nat_public_ip" {
  description = "IP publique de sortie (NAT Gateway)"
  value       = module.network.nat_public_ip
}
