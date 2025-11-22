# Terraform GitHub Actions Pipeline

This GitHub Actions workflow automates the deployment of AWS VPC and EC2 resources using Terraform.

## Workflow Overview

The `terraform-deploy.yml` pipeline performs the following actions:

### Triggers
- **Push to main**: Runs full Terraform plan and auto-applies changes
- **Pull Requests**: Runs Terraform plan and posts results as PR comment
- **File changes**: Only triggers when files in `Terraform/` directory change

### Pipeline Stages

1. **Format Check** - Validates Terraform code formatting
2. **Initialize** - Runs `terraform init` to setup backend
3. **Validate** - Validates Terraform configuration syntax
4. **Plan** - Generates execution plan without applying
5. **Apply** (main branch only) - Applies changes automatically on push to main
6. **Output** - Displays Terraform outputs (VPC ID, EC2 instance details)
7. **Artifacts** - Uploads plan files for audit trail

## Setup Instructions

### 1. Configure AWS Credentials in GitHub Secrets

Go to your GitHub repository → Settings → Secrets and variables → Actions

Add the following secrets:
- `AWS_ACCESS_KEY_ID` - Your AWS access key ID
- `AWS_SECRET_ACCESS_KEY` - Your AWS secret access key

**To generate AWS credentials:**
```bash
# Create IAM user with programmatic access
aws iam create-user --user-name github-actions
aws iam attach-user-policy --user-name github-actions --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

# Generate access keys
aws iam create-access-key --user-name github-actions
```

### 2. Commit and Push Changes

```bash
git add .github/workflows/terraform-deploy.yml
git commit -m "Add Terraform GitHub Actions pipeline"
git push origin main
```

## Workflow Behavior

### On Push to Main
✅ Runs Terraform plan  
✅ Automatically applies changes (`terraform apply`)  
✅ Outputs VPC ID, Subnet ID, EC2 Instance ID, Public IP  
✅ Stores plan artifacts for 5 days  

### On Pull Request
✅ Runs Terraform plan  
✅ Posts plan output as PR comment  
❌ Does NOT apply changes  
✅ Allows review before merge  

### Destroy Resources (Optional)
Include `[destroy]` in your commit message to trigger resource destruction:
```bash
git commit -m "Cleanup AWS resources [destroy]"
git push origin main
```

## Monitoring Deployments

1. Go to GitHub → Actions tab
2. Click on the "Terraform VPC and EC2 Deployment" workflow
3. View logs for each step
4. Check deployment status in job summary

## Resource Created

### VPC
- CIDR: `10.0.0.0/16`
- DNS enabled for service discovery

### Public Subnet
- CIDR: `10.0.1.0/24`
- Auto-assign public IPs enabled
- Availability Zone: `us-east-1a`

### Internet Gateway
- Routes all traffic to the internet

### Security Group
- Inbound: SSH (port 22), HTTP (port 80)
- Outbound: All traffic allowed

### EC2 Instance
- Type: `t2.micro` (free tier eligible)
- Public IP: Automatically assigned
- Key pair: `aws-project-example` (must exist in AWS)

## Troubleshooting

### Pipeline Fails with "Failed to configure provider"
**Cause**: AWS credentials not configured  
**Fix**: 
1. Verify `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` are set in GitHub Secrets
2. Ensure credentials have permission to create EC2, VPC, and Security Groups

### Pipeline Fails with "InvalidKeyPair.NotFound"
**Cause**: Key pair `aws-project-example` doesn't exist in AWS  
**Fix**: Update `Terraform/variables.tf` with an existing key pair name

### Pipeline Fails with "No subnets found"
**Cause**: VPC doesn't have any subnets  
**Fix**: This should not occur with the current pipeline. If it does, run `terraform validate`

## Environment Variables

- `AWS_REGION`: us-east-1 (configurable in workflow)
- `TF_VERSION`: 1.5.0 (matches provider requirement)

## Next Steps

1. Set up AWS credentials in GitHub Secrets
2. Push changes to trigger the pipeline
3. Monitor the workflow in the Actions tab
4. Verify resources in AWS Console

## Rolling Back Changes

To destroy resources:
```bash
# Manual destroy via CLI
cd Terraform
terraform destroy -auto-approve

# Or trigger via pipeline
git commit -m "Cleanup [destroy]"
git push origin main
```

## Files Modified

- `.github/workflows/terraform-deploy.yml` - GitHub Actions pipeline configuration
- Existing Terraform files: `main.tf`, `variables.tf`, `outputs.tf`, `provider.tf`
