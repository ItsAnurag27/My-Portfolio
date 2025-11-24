# How to Add AWS Credentials to GitHub Secrets

## Quick Steps

### 1. Get Your AWS Credentials

If you don't have AWS IAM credentials yet:

- Go to **AWS Console** → **IAM** → **Users** → **Create user**
- Name: `github-actions-terraform`
- Click **Next** → Choose **Attach policies directly**
- Attach: `EC2FullAccess` and `VPCFullAccess`
- Click **Next** → **Create user**
- Go to **Security credentials** tab
- Click **Create access key** → Select **GitHub Actions**
- **Copy** the Access Key ID and Secret Access Key

### 2. Add Secrets to GitHub

Go to your repository:

```text
https://github.com/ItsAnurag27/My-Portfolio/settings/secrets/actions
```

Click **New repository secret** and add these TWO secrets:

#### Secret 1 - AWS_ACCESS_KEY_ID

- **Name**: `AWS_ACCESS_KEY_ID`
- **Secret**: (paste your Access Key ID)
- Click **Add secret**

#### Secret 2 - AWS_SECRET_ACCESS_KEY

- **Name**: `AWS_SECRET_ACCESS_KEY`
- **Secret**: (paste your Secret Access Key)
- Click **Add secret**

### 3. Verify Secrets Were Added

In the same page, you should now see:

- ✅ AWS_ACCESS_KEY_ID
- ✅ AWS_SECRET_ACCESS_KEY

### 4. Trigger the Pipeline

Push changes to the `Terraform/` folder:

```bash
cd c:\Users\ms\My-Portfolio
git add Terraform/
git commit -m "Trigger pipeline with AWS credentials"
git push origin main
```

Then go to:

```text
https://github.com/ItsAnurag27/My-Portfolio/actions
```

And watch the pipeline run!

## Troubleshooting

### Still getting credential errors?

1. Verify secrets are added at: `github.com/ItsAnurag27/My-Portfolio/settings/secrets/actions`
2. Check secret names are EXACTLY:
   - `AWS_ACCESS_KEY_ID` (uppercase with underscores)
   - `AWS_SECRET_ACCESS_KEY` (uppercase with underscores)
3. Verify the credentials are valid in AWS:

```bash
aws configure
aws sts get-caller-identity
```

4. If credentials are invalid, create new ones in AWS IAM

### Need to rotate credentials?

1. Go to AWS IAM → Select the user → Security credentials
2. Deactivate old access key
3. Create new access key
4. Update both secrets in GitHub with the new values

---

**Still stuck?** Check the GitHub Actions logs at:
`https://github.com/ItsAnurag27/My-Portfolio/actions`

Click the failed workflow run and scroll down to see the exact error message.

