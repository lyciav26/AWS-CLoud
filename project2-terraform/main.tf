terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr              = "10.0.0.0/16"
  public_subnet_1_cidr  = "10.0.1.0/24"
  public_subnet_2_cidr  = "10.0.2.0/24"
  private_subnet_1_cidr = "10.0.11.0/24"
  private_subnet_2_cidr = "10.0.12.0/24"
  availability_zones    = ["us-east-1a", "us-east-1b"]
}

# Security Groups Module
module "security" {
  source = "./modules/security"
  
  vpc_id = module.vpc.vpc_id
}

# S3 Module
module "s3" {
  source = "./modules/s3"
}

# Secrets Manager for DB Password
resource "random_password" "db_password" {
  length  = 16
  special = true
}

resource "random_id" "secret_suffix" {
  byte_length = 4
}

resource "aws_secretsmanager_secret" "db_password" {
  name = "project2-db-password-${random_id.secret_suffix.hex}"
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    username = "admin"
    password = random_password.db_password.result
    engine   = "mysql"
    host     = module.rds.endpoint
    port     = 3306
    dbname   = "project2db"
  })
}

# IAM Module
module "iam" {
  source = "./modules/iam"
  
  s3_bucket_arn = module.s3.bucket_arn
  db_secret_arn = aws_secretsmanager_secret.db_password.arn
}

# RDS Module (Damia will create this)
module "rds" {
  source = "./modules/rds"
  
  vpc_id                 = module.vpc.vpc_id
  private_subnet_ids     = module.vpc.private_subnet_ids
  db_security_group_id   = module.security.db_sg_id
  db_password_secret_arn = aws_secretsmanager_secret.db_password.arn
}

# EC2 Module (Lycia will create this)
module "ec2" {
  source = "./modules/ec2"
  
  vpc_id                = module.vpc.vpc_id
  public_subnet_id      = module.vpc.public_subnet_ids[0]
  web_security_group_id = module.security.web_sg_id
  iam_instance_profile  = module.iam.instance_profile_name
  db_endpoint           = module.rds.endpoint
  db_secret_name        = aws_secretsmanager_secret.db_password.name
  s3_bucket_name        = module.s3.bucket_name
}