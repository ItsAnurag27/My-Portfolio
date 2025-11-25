# My Portfolio - Deployed on AWS with Terraform & Docker

## 🚀 Project Overview

This is a fully automated infrastructure-as-code deployment of a portfolio website using:
- **Terraform**: Infrastructure provisioning on AWS
- **Docker**: Containerized application deployment
- **GitHub Actions**: CI/CD pipeline for automated deployments
- **AWS Services**: VPC, EC2, Internet Gateway, Security Groups

## 📍 Live Application

Your portfolio is **live and accessible** at:
```
http://3.237.100.158
```

## 🏗️ Architecture

```
┌─────────────────────────────────────────────┐
│         GitHub Repository (Main)            │
│  ┌──────────────────────────────────────┐  │
│  │  GitHub Actions CI/CD Pipeline       │  │
│  │  - Terraform Plan & Apply            │  │
│  │  - Auto-commit state files           │  │
│  └──────────────────────────────────────┘  │
└────────────────┬────────────────────────────┘
                 │
                 ▼
        ┌────────────────────┐
        │   AWS Account      │
        │  (us-east-1)       │
        └────────┬───────────┘
                 │
        ┌────────▼───────────────────┐
        │    VPC: 10.0.0.0/16        │
        │                            │
        │  ┌──────────────────────┐  │
        │  │ Public Subnet        │  │
        │  │ 10.0.1.0/24          │  │
        │  │                      │  │
        │  │ ┌────────────────┐   │  │
        │  │ │ EC2 Instance   │   │  │
        │  │ │ t2.micro       │   │  │
        │  │ │                │   │  │
        │  │ │ ┌────────────┐ │   │  │
        │  │ │ │ Docker     │ │   │  │
        │  │ │ │ Container  │ │   │  │
        │  │ │ │ Nginx Port │ │   │  │
        │  │ │ │ 80         │ │   │  │
        │  │ │ └────────────┘ │   │  │
        │  │ └────────────────┘   │  │
        │  └──────────────────────┘  │
        └────────────────────────────┘
```

## 📁 Directory Structure

```
My-Portfolio/
├── Terraform/                 # Infrastructure as Code
│   ├── main.tf               # VPC, EC2, Security Groups, Docker deployment
│   ├── variables.tf          # Variable definitions
│   ├── outputs.tf            # Output values (IP, DNS, IDs)
│   ├── provider.tf           # AWS provider configuration
│   ├── terraform.tfstate     # Current infrastructure state
│   ├── terraform.tfvars.example  # Example variables template
│   └── .gitignore            # Git ignore rules
│
├── .github/workflows/
│   └── terraform-deploy.yml  # GitHub Actions CI/CD pipeline
│
├── assets/                   # Portfolio assets
│   ├── certificate/          # Certificates
│   └── project/              # Project files
│
├── index.html                # Portfolio page
├── style.css                 # Styling
├── mediaquaries.css          # Responsive design
├── script.js                 # JavaScript
├── Dockerfile                # Docker image configuration
├── docker-compose.yml        # Docker compose (reference)
│
└── Documentation files       # Setup guides
```

## 🔧 Quick Start

### 1. **View Your Live Portfolio**
Simply visit: `http://3.237.100.158`

### 2. **Infrastructure Details**
To see your AWS resources and current state:
```powershell
cd Terraform
terraform show
```

### 3. **Check Deployed Container**
To verify Docker container is running (requires SSH key setup):
```powershell
ssh -i "$env:USERPROFILE\.ssh\my-portfolio-key-2.pem" ec2-user@3.237.100.158
sudo docker ps
```

### 4. **Update Infrastructure**
Make changes to Terraform files, then:
```powershell
cd Terraform
terraform plan      # Preview changes
terraform apply     # Apply changes (or push to trigger CI/CD)
```

## 🔑 Key Information

| Item | Value |
|------|-------|
| **Public IP** | 3.237.100.158 |
| **Public DNS** | ec2-3-237-100-158.compute-1.amazonaws.com |
| **Instance ID** | i-00141aa9bf0dccc75 |
| **Instance Type** | t2.micro |
| **Region** | us-east-1 |
| **VPC** | vpc-03b3bdd4c45efcbd7 |
| **Subnet** | subnet-035229636045fdad1 |
| **SSH Key** | my-portfolio-key-2 |
| **SSH Key Path** | `~/.ssh/my-portfolio-key-2.pem` |

## 🔐 Security

- **SSH Access**: Port 22 (restricted by Security Group)
- **HTTP Access**: Port 80 (public)
- **HTTPS**: Can be added via AWS Certificate Manager + ALB
- **Security Group**: Allows SSH from anywhere + HTTP from anywhere
  - For production: Restrict SSH to your IP only

## 📋 Terraform Configuration

### VPC Setup
- **CIDR Block**: 10.0.0.0/16
- **Public Subnet**: 10.0.1.0/24
- **Internet Gateway**: Connected to VPC
- **Route Table**: Routes 0.0.0.0/0 → IGW

### EC2 Instance
- **AMI**: Amazon Linux 2 (ami-0fa3fe0fa7920f68e)
- **Instance Type**: t2.micro (free tier eligible)
- **Auto-start Services**: Docker engine
- **User Data**: Clones repo, builds Docker image, runs container

### Docker Deployment
On EC2 startup, the user data script:
1. Installs Docker
2. Clones your GitHub repository
3. Builds Docker image: `my-portfolio:latest`
4. Runs container on port 80 with Nginx

## 🚀 CI/CD Pipeline

**Trigger**: Push to `main` branch

**Steps**:
1. Terraform format check (`terraform fmt`)
2. Terraform validation (`terraform validate`)
3. Terraform plan (`terraform plan`)
4. Terraform apply (`terraform apply`) on main branch only
5. Auto-commit state files back to repo

**Requirements**:
- GitHub Secrets configured:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`

## 📝 Next Steps

### Optional: Enable HTTPS
1. Get an SSL certificate via AWS Certificate Manager
2. Add Application Load Balancer (ALB)
3. Update DNS records to point to ALB

### Optional: Improve Security
```hcl
# Restrict SSH to your IP only in security group
ingress {
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["YOUR_PUBLIC_IP/32"]
}
```

### Optional: Use a Domain Name
1. Register domain (Route 53 or external)
2. Create Route 53 hosted zone
3. Add A record pointing to your EC2 public IP

### Optional: Add RDS Database
Update `Terraform/main.tf` to add RDS MySQL/PostgreSQL instance

## 🐳 Docker Commands

SSH into instance:
```bash
ssh -i ~/.ssh/my-portfolio-key-2.pem ec2-user@3.237.100.158
```

View running containers:
```bash
sudo docker ps
```

View container logs:
```bash
sudo docker logs my-portfolio-app
```

Rebuild and restart container:
```bash
cd My-Portfolio
sudo docker build -t my-portfolio:latest .
sudo docker stop my-portfolio-app
sudo docker rm my-portfolio-app
sudo docker run -d --name my-portfolio-app -p 80:80 my-portfolio:latest
```

## 📊 Monitoring & Logs

### View EC2 System Logs
```powershell
aws ec2 get-console-output --instance-id i-00141aa9bf0dccc75 --region us-east-1
```

### View Terraform State
```powershell
cd Terraform
terraform state show
```

## ⚠️ Important Notes

1. **State File**: Currently stored in Git (Terraform best practice suggests remote backend like S3 for production)
2. **Cost**: t2.micro is free tier eligible, but charges apply for data transfer and static IP (if assigned)
3. **Backups**: State file backups should be configured for production
4. **Scaling**: For high traffic, consider adding Application Load Balancer

## 🆘 Troubleshooting

**Container not running after EC2 startup?**
- SSH into instance and check: `sudo docker logs my-portfolio-app`
- Verify Docker service: `sudo systemctl status docker`

**Can't connect to portfolio?**
- Verify Security Group allows HTTP (port 80)
- Check instance is in running state: `aws ec2 describe-instances --instance-ids i-00141aa9bf0dccc75 --region us-east-1`

**SSH key issues?**
- Ensure correct key: `my-portfolio-key-2.pem`
- Verify permissions: `ls -la ~/.ssh/my-portfolio-key-2.pem` (should show `-rw-------`)

## 📚 Additional Resources

- [Terraform AWS Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Docker Documentation](https://docs.docker.com/)
- [AWS Free Tier](https://aws.amazon.com/free/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

---

**Last Updated**: November 25, 2025  
**Status**: ✅ Live and Running
