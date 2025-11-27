variable "aws_region" {
  description = "AWS region to create resources in"
  type        = string
  default     = "us-east-1"
}

variable "instance_ami" {
  description = "AMI ID for EC2 instance"
  type        = string
  # Example: Amazon Linux 2 in ap-south-1 (update as needed)
  default     = "ami-0fa3fe0fa7920f68e"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "instance_name" {
  description = "Name tag for EC2 instance"
  type        = string
  default     = "my-ec2-instance"
}

variable "key_name" {
  description = "Existing key pair name in AWS"
  type        = string
  default = "demo"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

