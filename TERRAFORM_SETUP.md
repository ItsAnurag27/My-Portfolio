# Terraform CI/CD Pipeline Setup Guide

This guide explains how to set up the GitHub Actions workflow for Terraform VPC and EC2 deployment.

## Prerequisites

1. AWS Account with appropriate permissions
2. GitHub Repository access
3. AWS IAM credentials (Access Key and Secret Key)

## Step 1: Create AWS IAM User for GitHub Actions

1. Go to AWS IAM Console → Users
2. Click "Create user" and name it `github-actions-terraform`
3. Click "Next" → Choose "Attach policies directly"
4. Search for and attach these policies:
   - `EC2FullAccess`
   - `VPCFullAccess`
   - `SecurityGroupsFullAccess` (or just include in EC2FullAccess)

5. Click "Next" → "Create user"
6. Go to the user's "Security credentials" tab
7. Click "Create access key" → Select "GitHub Actions" → Click "Next"
8. Copy the **Access Key** and **Secret Access Key**

## Step 2: Add AWS Secrets to GitHub Repository

1. Go to your GitHub repository: `https://github.com/ItsAnurag27/My-Portfolio`
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret** and add:
   - **Name**: `AWS_ACCESS_KEY_ID`
   - **Secret**: (paste the Access Key from Step 1)
4. Click **Add secret**
5. Click **New repository secret** again and add:
   - **Name**: `AWS_SECRET_ACCESS_KEY`
   - **Secret**: (paste the Secret Access Key from Step 1)
6. Click **Add secret**

## Step 3: Verify the Pipeline Configuration

The pipeline is configured to:

### Trigger Events
- **Push to main branch** with changes in `Terraform/` folder
- **Pull requests** to main branch with changes in `Terraform/` folder

### Workflow Steps
1. **Checkout Code** - Pulls the latest code
2. **Setup Terraform** - Installs Terraform v1.5.0
3. **Configure AWS Credentials** - Uses GitHub secrets to authenticate with AWS
4. **Format Check** - Validates Terraform code formatting
5. **Terraform Init** - Initializes Terraform in the Terraform directory
6. **Terraform Validate** - Validates Terraform configuration
7. **Terraform Plan** - Creates a plan of infrastructure changes
8. **PR Comment** - Posts plan output as a comment on pull requests
9. **Terraform Apply** - Applies changes on main branch pushes (auto-approved)
10. **Terraform Output** - Displays outputs in GitHub Actions summary
11. **Upload Artifacts** - Saves plan files for review

## Step 4: Deploy

### Option A: Automatic Deployment (Recommended for testing)

1. Make changes to any file in the `Terraform/` directory
2. Commit and push to main branch:
   ```bash
   git add Terraform/
   git commit -m "Add VPC and EC2 resources"
   git push origin main
   ```
3. GitHub Actions will automatically:
   - Run `terraform plan`
   - Run `terraform apply -auto-approve`
   - Create the VPC and EC2 instance

### Option B: Pull Request Workflow (Better for production)

1. Create a feature branch:
   ```bash
   git checkout -b feat/terraform-infrastructure
   ```
2. Make changes to Terraform files
3. Commit and push:
   ```bash
   git add Terraform/
   git commit -m "Add VPC and EC2 resources"
   git push origin feat/terraform-infrastructure
   ```
4. Create a Pull Request on GitHub
5. The pipeline will:
   - Run `terraform plan`
   - Post the plan as a comment on the PR
   - Wait for approval
6. After review and approval, merge the PR to main
7. The pipeline will automatically `terraform apply`

## Step 5: Monitor Deployment

1. Go to your GitHub repository
2. Click **Actions** tab
3. Click the latest workflow run
4. View real-time logs of each step
5. Check for any errors or failures

## Terraform Variables

The following variables can be customized in `Terraform/terraform.tfvars` (create this file):

```hcl
aws_region          = "us-east-1"
vpc_cidr            = "10.0.0.0/16"
public_subnet_cidr  = "10.0.1.0/24"
instance_type       = "t2.micro"
instance_name       = "my-ec2-instance"
key_name            = "aws-project-example"  # Must exist in your AWS account
instance_ami        = "ami-0fa3fe0fa7920f68e" # For us-east-1
```

## Outputs After Deployment

After successful deployment, the workflow will output:
- `vpc_id` - ID of the created VPC
- `public_subnet_id` - ID of the public subnet
- `instance_id` - ID of the EC2 instance
- `public_ip` - Public IP address of the EC2 instance
- `public_dns` - Public DNS name of the EC2 instance

## Troubleshooting

### Issue: "InvalidAMIID.NotFound"
- The AMI ID in `variables.tf` is specific to `us-east-1`
- Update the `instance_ami` variable if using a different region

### Issue: "InvalidKeyPair"
- The key pair must exist in your AWS account in the specified region
- Create a key pair in AWS EC2 console before applying

### Issue: "Access Denied" errors
- Verify AWS IAM credentials are correct in GitHub Secrets
- Check that the IAM user has the required permissions

### Issue: Terraform state files
- State files are not committed to git (see `.gitignore`)
- Consider using S3 backend for state management in production

## Optional: S3 Backend for State Management

For production deployments, store Terraform state in S3:

1. Create an S3 bucket in AWS:
   ```bash
   aws s3 mb s3://my-portfolio-terraform-state --region us-east-1
   ```

2. Create `Terraform/backend.tf`:
   ```hcl
   terraform {
     backend "s3" {
       bucket         = "my-portfolio-terraform-state"
       key            = "prod/terraform.tfstate"
       region         = "us-east-1"
       encrypt        = true
       dynamodb_table = "terraform-locks"
     }
   }
   ```

3. Add the following secrets to GitHub:
   - `AWS_TERRAFORM_BUCKET` = bucket name
   - Update IAM policy to include S3 and DynamoDB permissions

## Next Steps

1. Complete Steps 1-2 (AWS setup and GitHub Secrets)
2. Push changes to trigger the pipeline
3. Monitor the Actions tab for deployment status
4. Verify VPC and EC2 are created in AWS Console
5. Connect to your EC2 instance using the key pair and public IP

For more information, see the [Terraform Documentation](https://www.terraform.io/docs) and [GitHub Actions Documentation](https://docs.github.com/en/actions).
