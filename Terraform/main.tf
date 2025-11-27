############################################
# VPC + EC2 for Docker App (My-Portfolio)
############################################

# NOTE:
# - This file assumes you already defined:
#     var.vpc_cidr
#     var.public_subnet_cidr
#     var.aws_region
#     var.instance_ami
#     var.instance_type
#     var.key_name
#     var.instance_name
#   in variables.tf or somewhere else.

############################################
# VPC
############################################

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

############################################
# Public Subnet
############################################

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

############################################
# Internet Gateway
############################################

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      vpc_id
    ]
  }
}

############################################
# Route Table + Association
############################################

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
    ignore_changes = [
      vpc_id,
      route
    ]
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

############################################
# Security Group (SSH + HTTP)
############################################

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

############################################
# EC2 Instance
############################################

resource "aws_instance" "ec-2" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = aws_subnet.public.id

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  # User data script: install Docker, clone repo, build and run container
  user_data = <<-EOF
              #!/bin/bash
              set -x
              exec > >(tee /var/log/user-data.log)
              exec 2>&1

              echo "=== Starting user data script ==="
              yum update -y

              echo "Installing Docker..."
              yum install -y docker git

              echo "Enabling and starting Docker..."
              systemctl enable docker
              systemctl start docker

              echo "Cloning GitHub repository..."
              cd /home/ec2-user
              git clone https://github.com/ItsAnurag27/My-Portfolio.git
              cd My-Portfolio

              echo "Building Docker image..."
              docker build -t my-portfolio:latest .

              echo "Running Docker container..."
              docker run -d --name my-portfolio-app -p 80:80 my-portfolio:latest

              echo "Setting up auto-update script..."
              cat > /home/ec2-user/update-portfolio.sh << 'EOSCRIPT'
#!/bin/bash
set -x
exec >> /var/log/portfolio-updates.log 2>&1

echo "=== Portfolio Update Check at $(date) ==="

cd /home/ec2-user/My-Portfolio

# Fetch latest code
git fetch origin main

# Check if there are new commits
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)

if [ "$LOCAL" != "$REMOTE" ]; then
  echo "New commits found! Updating..."
  git pull origin main
  docker build -t my-portfolio:latest .
  docker stop my-portfolio-app || true
  docker rm my-portfolio-app || true
  docker run -d --name my-portfolio-app -p 80:80 my-portfolio:latest
else
  echo "No new updates available."
fi
EOSCRIPT

              chmod +x /home/ec2-user/update-portfolio.sh
              chown ec2-user:ec2-user /home/ec2-user/update-portfolio.sh

              echo "Adding cron job for auto-updates..."
              (crontab -u ec2-user -l 2>/dev/null; echo "*/2 * * * * /home/ec2-user/update-portfolio.sh") | crontab -u ec2-user -

              echo "=== User data script completed ==="
              EOF

  tags = {
    Name = var.instance_name
  }

  # Strong protection: don't let Terraform recreate this EC2 for small changes
  lifecycle {
    prevent_destroy       = true
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
