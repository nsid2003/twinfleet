output "db_address" {
  description = "Nom DNS de l'instance RDS"
  value       = aws_db_instance.this.address
}

output "db_port" {
  description = "Port de l'instance RDS"
  value       = aws_db_instance.this.port
}

output "db_secret_arn" {
  description = "ARN du secret Secrets Manager géré par RDS"
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}

output "bucket_name" {
  description = "Nom du bucket S3 applicatif"
  value       = aws_s3_bucket.assets.bucket
}

output "bucket_arn" {
  description = "ARN du bucket S3 applicatif"
  value       = aws_s3_bucket.assets.arn
}
