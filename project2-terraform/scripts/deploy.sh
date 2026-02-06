#!/bin/bash
set -e

echo "======================================"
echo "Project 2 - Infrastructure Deployment"
echo "======================================"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}ERROR: Terraform not installed${NC}"
    exit 1
fi

# Initialize
echo -e "${GREEN}Initializing Terraform...${NC}"
terraform init

# Validate
echo -e "${GREEN}Validating configuration...${NC}"
terraform validate

# Plan
echo -e "${GREEN}Planning deployment...${NC}"
terraform plan -out=tfplan

# Ask for confirmation
read -p "Deploy infrastructure? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Deployment cancelled"
    exit 0
fi

# Apply
echo -e "${GREEN}Deploying infrastructure...${NC}"
terraform apply tfplan

# Show outputs
echo -e "${GREEN}Deployment complete!${NC}"
echo ""
echo "======================================"
echo "OUTPUTS:"
echo "======================================"
terraform output

echo ""
echo -e "${GREEN}Next steps:${NC}"
echo "1. SSH to EC2: ssh -i key.pem ubuntu@\$(terraform output -raw ec2_public_ip)"
echo "2. Deploy application"
echo "3. Access via: https://\$(terraform output -raw ec2_public_ip)"