output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "ec2_public_ip" {
  description = "EC2 Public IP"
  value       = module.ec2.public_ip
}

output "rds_endpoint" {
  description = "RDS Endpoint"
  value       = module.rds.endpoint
}

output "s3_bucket_name" {
  description = "S3 Bucket Name"
  value       = module.s3.bucket_name
}

output "db_secret_name" {
  description = "Database Secret Name"
  value       = aws_secretsmanager_secret.db_password.name
}