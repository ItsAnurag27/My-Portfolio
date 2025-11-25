# Terraform Configuration for VPC and EC2 Deployment
# Pipeline trigger - ready for deployment

# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "main-vpc"
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
}

# Create internet gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
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
              set -e
              
              echo "Updating system packages..."
              yum update -y
              
              echo "Installing Docker..."
              yum install -y docker git
              
              echo "Starting Docker service..."
              systemctl start docker
              systemctl enable docker
              
              echo "Adding ec2-user to docker group..."
              usermod -a -G docker ec2-user
              
              echo "Cloning repository..."
              cd /tmp
              git clone https://github.com/ItsAnurag27/My-Portfolio.git
              cd My-Portfolio
              
              echo "Building Docker image..."
              docker build -t my-portfolio:latest .
              
              echo "Running Docker container..."
              docker run -d --name my-portfolio-app -p 80:80 my-portfolio:latest
              
              echo "Docker container started successfully!"
              docker ps
              EOF
  )

  tags = {
    Name = var.instance_name
  }
}
