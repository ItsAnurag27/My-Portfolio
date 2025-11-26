# Terraform Configuration for VPC and EC2 Deployment
# SOLUTION: Use ignore_changes on all resources to prevent recreation
# This ensures infrastructure is never recreated

# Data source to find existing EC2 instance by tag
data "aws_instances" "existing" {
  filter {
    name   = "tag:Name"
    values = [var.instance_name]
  }

  filter {
    name   = "instance-state-name"
    values = ["running", "stopped"]
  }

  depends_on = [aws_vpc.main]
}

# Check if EC2 instance already exists
locals {
  instance_exists = length(data.aws_instances.existing.ids) > 0
  existing_instance_id = length(data.aws_instances.existing.ids) > 0 ? data.aws_instances.existing.ids[0] : null
}

# Create VPC aws
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "main-vpc"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      cidr_block,
      enable_dns_hostnames,
      enable_dns_support
    ]
  }
}

# Create public subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      vpc_id,
      cidr_block,
      availability_zone,
      map_public_ip_on_launch
    ]
  }
}

# Create internet gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = [vpc_id]
  }
}

# Create route table for public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-rt"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = [vpc_id, route]
  }
}

# Associate route table with public subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2-ssh-http-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-ssh-http-sg"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      vpc_id,
      ingress,
      egress,
      name,
      description
    ]
  }
}

resource "aws_instance" "ec-2" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = aws_subnet.public.id

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  # User data script to install Docker and deploy container
  user_data = base64encode(<<-EOF
              #!/bin/bash
              set -x
              exec > >(tee /var/log/user-data.log)
              exec 2>&1
              
              echo "=== Starting user data script ==="
              echo "Updating system packages..."
              yum update -y
              
              echo "Installing Docker..."
              yum install -y docker git
              
              echo "Starting Docker service..."
              systemctl start docker
              systemctl enable docker
              
              echo "Waiting for Docker to be ready..."
              sleep 5
              
              echo "Cloning repository..."
              cd /home/ec2-user
              git clone https://github.com/ItsAnurag27/My-Portfolio.git
              cd My-Portfolio
              
              echo "Building Docker image..."
              docker build -t my-portfolio:latest .
              
              echo "Running Docker container..."
              docker run -d --name my-portfolio-app -p 80:80 my-portfolio:latest
              
              echo "Creating update script..."
              cat > /home/ec2-user/update-portfolio.sh << 'SCRIPT'
              #!/bin/bash
              set -x
              exec >> /var/log/portfolio-updates.log 2>&1
              
              echo "=== Portfolio Update Check at $(date) ==="
              
              cd /home/ec2-user/My-Portfolio
              
              # Fetch latest code
              echo "Fetching latest code..."
              git fetch origin main
              
              # Check if there are new commits
              LOCAL=$(git rev-parse HEAD)
              REMOTE=$(git rev-parse origin/main)
              
              if [ "$LOCAL" != "$REMOTE" ]; then
                echo "New commits found! Updating..."
                git pull origin main
                
                echo "Rebuilding Docker image..."
                docker build -t my-portfolio:latest .
                
                echo "Stopping old container..."
                docker stop my-portfolio-app || true
                docker rm my-portfolio-app || true
                
                echo "Starting new container..."
                docker run -d --name my-portfolio-app -p 80:80 my-portfolio:latest
                
                echo "Container restarted successfully!"
              else
                echo "No new updates available."
              fi
              
              echo "=== Update check complete ==="
              SCRIPT
              
              chmod +x /home/ec2-user/update-portfolio.sh
              
              echo "Setting up cron job to check for updates every 2 minutes..."
              echo "*/2 * * * * /home/ec2-user/update-portfolio.sh" | crontab -
              
              systemctl start crond
              systemctl enable crond
              
              echo "Verifying container..."
              docker ps
              echo "=== User data script completed ==="
              EOF
  )

  tags = {
    Name = var.instance_name
  }

  # ============ ULTIMATE PROTECTION ============
  # NEVER recreate EC2 - IGNORE ALL CHANGES
  # This is the key - we tell Terraform to ignore infrastructure changes
  lifecycle {
    prevent_destroy = true
    create_before_destroy = false
    ignore_changes = [
      ami,
      user_data,
      instance_type,
      key_name,
      subnet_id,
      vpc_security_group_ids,
      root_block_device,
      ebs_block_device,
      associate_public_ip_address,
      ipv6_address_count,
      ipv6_addresses,
      security_groups,
      source_dest_check,
      tags,
      tenancy,
      monitoring
    ]
  }
}
