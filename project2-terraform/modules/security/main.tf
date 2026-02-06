# Web Server Security Group
resource "aws_security_group" "web_sg" {
  name        = "project2-web-sg"
  description = "Security group for web servers"
  vpc_id      = var.vpc_id
  
  # HTTP
  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # HTTPS
  ingress {
    description = "HTTPS from Internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # SSH (restrict to your IP!)
  ingress {
    description = "SSH from Admin IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # CHANGE THIS to your actual IP!
  }
  
  # Outbound - allow all (for simplicity)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "project2-web-sg"
    Tier = "Web"
  }
}

# Database Security Group
resource "aws_security_group" "db_sg" {
  name        = "project2-db-sg"
  description = "Security group for RDS database"
  vpc_id      = var.vpc_id
  
  # MySQL from Web SG ONLY
  ingress {
    description     = "MySQL from Web Servers"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }
  
  # NO outbound rules needed for database
  
  tags = {
    Name = "project2-db-sg"
    Tier = "Database"
  }
}