# Project 2: Secure AWS Migration - Infrastructure as Code

## Overview
This Terraform configuration deploys a secure, highly available AWS architecture for a migrated legacy application.

## Architecture Components
- VPC with public and private subnets across 2 AZs
- EC2 instance in public subnet (web tier)
- RDS MySQL in private subnet (database tier)
- S3 bucket with encryption (storage)
- Security Groups (network security)
- IAM Roles (access control)
- Secrets Manager (credential management)

## Prerequisites
- Terraform >= 1.0
- AWS CLI configured
- AWS Account with appropriate permissions

## Deployment

### 1. Clone Repository
```bash
git clone https://github.com/your-team/project2-terraform.git
cd project2-terraform
```

### 2. Configure Variables
```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars if needed
```

### 3. Initialize Terraform
```bash
terraform init
```

### 4. Review Plan
```bash
terraform plan
```

### 5. Deploy Infrastructure
```bash
terraform apply
```

### 6. Get Outputs
```bash
terraform output
```

## Accessing the Application
After deployment:
1. Get EC2 public IP: `terraform output ec2_public_ip`
2. SSH to instance: `ssh -i key.pem ubuntu@<public-ip>`
3. Access application: `https://<public-ip>`

## Security Features
✅ **Encryption at Rest**: RDS and S3 encrypted
✅ **Encryption in Transit**: SSL/TLS enforced
✅ **Network Isolation**: Database in private subnet
✅ **Least Privilege IAM**: Minimal permissions
✅ **Security Groups**: Restricted access rules
✅ **Secrets Management**: Credentials in Secrets Manager

## Cleanup
```bash
terraform destroy
```

## Team Members
- Maya (Networking & Security)
- Damia (Database)
- Lycia (Application)

## License
Academic Project - MMU CCS6344