# 🔐 Add GitHub Secrets - Step by Step

## The Problem

The GitHub Actions workflow is failing because AWS credentials aren't stored in GitHub Secrets.

The error message means:
```
Could not load credentials from any providers
```

This happens because GitHub doesn't have `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` secrets.

## Solution - Add Secrets to GitHub

### Step 1: Go to GitHub Settings

1. Open your browser
2. Go to: `https://github.com/ItsAnurag27/My-Portfolio/settings/secrets/actions`
3. You should see a page titled "Actions secrets"

### Step 2: Add First Secret - AWS_ACCESS_KEY_ID

1. Click the green button **"New repository secret"**
2. In the **"Name"** field, type exactly:
   ```
   AWS_ACCESS_KEY_ID
   ```
3. In the **"Secret"** field, paste:
   - Your AWS Access Key ID (from `aws configure`)
   - You can find it in: `C:\Users\ms\.aws\credentials`
4. Click **"Add secret"** button

### Step 3: Add Second Secret - AWS_SECRET_ACCESS_KEY

1. Click the green button **"New repository secret"** again
2. In the **"Name"** field, type exactly:
   ```
   AWS_SECRET_ACCESS_KEY
   ```
3. In the **"Secret"** field, paste:
   - Your AWS Secret Access Key (from `aws configure`)
   - You can find it in: `C:\Users\ms\.aws\credentials`
4. Click **"Add secret"** button

### Step 4: Verify Secrets Were Added

After adding both secrets, you should see:

```
✓ AWS_ACCESS_KEY_ID
✓ AWS_SECRET_ACCESS_KEY
```

Listed on the page. They will show as dots (hidden for security).

## How to Get Your AWS Credentials

Open PowerShell and run:

```powershell
cat $env:USERPROFILE\.aws\credentials
```

This will show something like:

```
[default]
aws_access_key_id = AKIAIOSFODNN7EXAMPLE
aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

Copy:
- `aws_access_key_id` value → paste into GitHub Secret `AWS_ACCESS_KEY_ID`
- `aws_secret_access_key` value → paste into GitHub Secret `AWS_SECRET_ACCESS_KEY`

## After Adding Secrets

Once secrets are added, the next pipeline run will work!

The pipeline will:
1. ✅ Read the secrets from GitHub
2. ✅ Configure AWS credentials
3. ✅ Run Terraform commands
4. ✅ Deploy VPC and EC2

## Trigger Pipeline Again

After adding secrets, push a change to trigger:

```powershell
cd 'c:\Users\ms\My-Portfolio'
git add Terraform/
git commit -m "Deploy with AWS credentials configured"
git push origin main
```

Then monitor at: `https://github.com/ItsAnurag27/My-Portfolio/actions`

---

**This is the ONLY remaining step!** Once secrets are added, your infrastructure deployment will work perfectly. 🚀
