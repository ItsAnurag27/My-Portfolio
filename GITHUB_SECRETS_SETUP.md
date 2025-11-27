# GitHub Secrets Setup Guide

## Overview
You need to add secrets to GitHub so the pipelines can authenticate with AWS and SSH into your EC2.

## GitHub Secrets to Add

### 1. AWS Credentials (for Terraform)
These are needed for the **infrastructure-setup.yml** pipeline to create VPC/EC2.

**Credential Name:** `AWS_ACCESS_KEY_ID`
- **Value:** Your AWS Access Key ID
- **Where to get:** AWS IAM Console → Your User → Security Credentials

**Credential Name:** `AWS_SECRET_ACCESS_KEY`
- **Value:** Your AWS Secret Access Key
- **Where to get:** AWS IAM Console → Your User → Security Credentials

---

### 2. EC2 Connection Details (for Deploy Pipeline)
These are needed for the **deploy-code.yml** pipeline to SSH into your EC2 and update the container.

**Credential Name:** `EC2_HOST`
- **Value:** `44.198.190.171` (Your EC2 Public IP)
- **How to find:** 
  ```powershell
  aws ec2 describe-instances --region us-east-1 --query 'Reservations[*].Instances[*].[PublicIpAddress]' --output text
  ```
  OR check AWS console → EC2 → Instances

**Credential Name:** `EC2_USER`
- **Value:** `ec2-user` (for Amazon Linux 2)
- **Note:** This is the default user for Amazon Linux 2 AMI

**Credential Name:** `EC2_SSH_KEY`
- **Value:** Your private SSH key content (entire key as text)
- **How to get:**
  ```powershell
  # On Windows PowerShell:
  Get-Content "C:\Users\ms\.ssh\my-portfolio-key-2.pem" -Raw
  
  # Copy the entire output including BEGIN and END lines
  ```
- **What it looks like:**
  ```
  -----BEGIN RSA PRIVATE KEY-----
  MIIEpAIBAAKCAQEA1q2z3...
  ...
  -----END RSA PRIVATE KEY-----
  ```

---

### 3. Docker Hub Credentials (Optional - for docker-publish.yml)

**Credential Name:** `DOCKERHUB_USERNAME`
- **Value:** Your Docker Hub username
- **Example:** `itsanurag27`

**Credential Name:** `DOCKERHUB_TOKEN`
- **Value:** Your Docker Hub access token (NOT your password)
- **How to create:**
  1. Go to Docker Hub → Account Settings → Security
  2. Click "New Access Token"
  3. Copy the token

---

## How to Add Secrets to GitHub

### Steps:

1. Go to your GitHub repository: **https://github.com/ItsAnurag27/My-Portfolio**

2. Click **Settings** → **Secrets and variables** → **Actions**

3. Click **New repository secret**

4. Add each secret:
   - **Name:** (exactly as listed above)
   - **Value:** (your actual value)
   - Click **Add secret**

5. Repeat for all required secrets

---

## Summary Table

| Secret Name | Value | Pipeline |
|---|---|---|
| `AWS_ACCESS_KEY_ID` | Your AWS Access Key | infrastructure-setup |
| `AWS_SECRET_ACCESS_KEY` | Your AWS Secret Key | infrastructure-setup |
| `EC2_HOST` | 44.198.190.171 | deploy-code |
| `EC2_USER` | ec2-user | deploy-code |
| `EC2_SSH_KEY` | Your private SSH key | deploy-code |
| `DOCKERHUB_USERNAME` | Your Docker Hub user | docker-publish (optional) |
| `DOCKERHUB_TOKEN` | Your Docker Hub token | docker-publish (optional) |

---

## How the Pipelines Work

### infrastructure-setup.yml
- **Triggers:** Manual (`workflow_dispatch`) OR when `Terraform/**` files change
- **Does:** Creates VPC, Subnet, IGW, Route Table, Security Group, EC2
- **Runs:** ONLY ONCE (uses prevent_destroy to keep resources)
- **Secrets needed:** `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`

### deploy-code.yml
- **Triggers:** Automatically when you change code files
- **Does:** SSH into EC2, pulls code, rebuilds Docker image, restarts container
- **Runs:** Every time you push code changes
- **Secrets needed:** `EC2_HOST`, `EC2_USER`, `EC2_SSH_KEY`

### docker-publish.yml (Optional)
- **Triggers:** Manual only (workflow_dispatch)
- **Does:** Builds and pushes Docker image to Docker Hub
- **Runs:** When you manually trigger it
- **Secrets needed:** `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`

---

## Testing

After adding all secrets:

1. Push a code change (changes `index.html`, `style.css`, etc.)
2. Go to **GitHub → Actions**
3. You should see **deploy-code** pipeline running
4. EC2 will update within 2 minutes (via cron job)
5. Your website updates automatically ✨

---

## Troubleshooting

### "Error: Secret is not defined"
- Make sure the secret name exactly matches (case-sensitive)
- Example: `EC2_HOST` NOT `ec2_host`

### "SSH Connection Failed"
- Verify `EC2_HOST` is correct (check AWS console)
- Verify `EC2_SSH_KEY` has entire private key (BEGIN and END lines)
- Make sure security group allows SSH (port 22)

### "EC2_SSH_KEY format is wrong"
- Should be the **private key**, not public key
- Should include BEGIN and END lines
- Should be one continuous string with `\n` for newlines

---

Done! Once you add all secrets, your pipelines are ready to go! 🚀
