# Quick Start: GitHub Actions Terraform Pipeline

## 1️⃣ Set Up AWS Credentials (5 minutes)

Go to GitHub Settings → Secrets and add:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

[Full instructions in TERRAFORM_SETUP.md](./TERRAFORM_SETUP.md)

## 2️⃣ Deploy Infrastructure

Push changes to the Terraform folder:

```bash
git add Terraform/
git commit -m "Deploy VPC and EC2"
git push origin main
```

The pipeline will automatically:

- ✅ Format check
- ✅ Validate Terraform config
- ✅ Create infrastructure plan
- ✅ Apply infrastructure
- ✅ Output resource IDs and IPs

## 3️⃣ Monitor Deployment

Check GitHub Actions tab for real-time logs.

## What Gets Created

- ✅ **VPC** (10.0.0.0/16)
- ✅ **Public Subnet** (10.0.1.0/24)
- ✅ **Internet Gateway** (for public internet access)
- ✅ **Route Table** (routes traffic to IGW)
- ✅ **Security Group** (allows SSH port 22 and HTTP port 80)
- ✅ **EC2 Instance** (t2.micro in public subnet)

## Useful Commands (Local Development)

```bash
# Navigate to Terraform directory
cd Terraform

# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Create a plan
terraform plan

# Apply changes (use with caution!)
terraform apply

# View outputs
terraform output

# Destroy infrastructure
terraform destroy
```

## Environment Variables in Workflow

- `AWS_REGION: us-east-1` - Change if needed
- `TF_VERSION: 1.5.0` - Terraform version used

## Next Steps

1. Follow [TERRAFORM_SETUP.md](./TERRAFORM_SETUP.md) to add AWS secrets
2. Push a change to trigger the pipeline
3. Monitor the Actions tab
4. Access your EC2 instance using the `public_ip` output

---

**Need Help?** Check the troubleshooting section in TERRAFORM_SETUP.md
