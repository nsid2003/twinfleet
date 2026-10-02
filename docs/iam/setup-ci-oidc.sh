#!/usr/bin/env bash
set -euo pipefail
export AWS_PAGER=""

REGION="eu-west-3"
OWNER="nsid2003"
REPO_NAME="twinfleet"
REPO_JSON=$(curl -fsS "https://api.github.com/repos/${OWNER}/${REPO_NAME}")
OWNER_ID=$(echo "$REPO_JSON" | jq -r .owner.id)
REPO_ID=$(echo "$REPO_JSON" | jq -r .id)
REPO="${OWNER}@${OWNER_ID}/${REPO_NAME}@${REPO_ID}"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
BUCKET="twinfleet-tfstate-$(openssl rand -hex 4)"
WORKDIR="$HOME/twinfleet-ci" && mkdir -p "$WORKDIR" && cd "$WORKDIR"

aws s3api create-bucket --bucket "$BUCKET" --region "$REGION" \
  --create-bucket-configuration LocationConstraint="$REGION" > /dev/null

aws s3api put-bucket-versioning --bucket "$BUCKET" \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption --bucket "$BUCKET" \
  --server-side-encryption-configuration \
  '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"},"BucketKeyEnabled":true}]}'

aws s3api put-public-access-block --bucket "$BUCKET" \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

cat > bucket-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Sid": "DenyInsecureTransport",
    "Effect": "Deny",
    "Principal": "*",
    "Action": "s3:*",
    "Resource": ["arn:aws:s3:::${BUCKET}", "arn:aws:s3:::${BUCKET}/*"],
    "Condition": { "Bool": { "aws:SecureTransport": "false" } }
  }]
}
EOF
aws s3api put-bucket-policy --bucket "$BUCKET" --policy file://bucket-policy.json
aws s3api put-bucket-tagging --bucket "$BUCKET" --tagging 'TagSet=[{Key=Project,Value=twinfleet}]'
echo ">> Bucket state : $BUCKET"

OIDC_ARN="arn:aws:iam::${ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"
if ! aws iam get-open-id-connect-provider --open-id-connect-provider-arn "$OIDC_ARN" > /dev/null 2>&1; then
  aws iam create-open-id-connect-provider \
    --url https://token.actions.githubusercontent.com \
    --client-id-list sts.amazonaws.com \
    --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1 1c58a3a8518e8759bf075b76b750d4f2df264fcd > /dev/null
fi
echo ">> OIDC : $OIDC_ARN"

cat > trust-plan.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": { "Federated": "${OIDC_ARN}" },
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {
      "StringEquals": { "token.actions.githubusercontent.com:aud": "sts.amazonaws.com" },
      "StringLike": {
        "token.actions.githubusercontent.com:sub": [
          "repo:${REPO}:pull_request",
          "repo:${REPO}:ref:refs/heads/main"
        ]
      }
    }
  }]
}
EOF
aws iam create-role --role-name gha-twinfleet-plan \
  --assume-role-policy-document file://trust-plan.json \
  --description "GitHub Actions - terraform plan (lecture seule)" \
  --tags Key=Project,Value=twinfleet > /dev/null
aws iam attach-role-policy --role-name gha-twinfleet-plan \
  --policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess

cat > plan-lock.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Sid": "WriteOnlyLockFiles",
    "Effect": "Allow",
    "Action": ["s3:PutObject", "s3:DeleteObject"],
    "Resource": "arn:aws:s3:::${BUCKET}/*.tflock"
  }]
}
EOF
aws iam put-role-policy --role-name gha-twinfleet-plan \
  --policy-name tfstate-lock --policy-document file://plan-lock.json

cat > trust-apply.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": { "Federated": "${OIDC_ARN}" },
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {
      "StringEquals": {
        "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
        "token.actions.githubusercontent.com:sub": [
          "repo:${REPO}:environment:staging",
          "repo:${REPO}:environment:production"
        ]
      }
    }
  }]
}
EOF
aws iam create-role --role-name gha-twinfleet-apply \
  --assume-role-policy-document file://trust-apply.json \
  --description "GitHub Actions - terraform apply (environnements approuves)" \
  --tags Key=Project,Value=twinfleet > /dev/null
for arn in \
  arn:aws:iam::aws:policy/PowerUserAccess \
  "arn:aws:iam::${ACCOUNT_ID}:policy/TwinFleet-IAM-Roles" \
  "arn:aws:iam::${ACCOUNT_ID}:policy/TwinFleet-Guardrails"; do
  aws iam attach-role-policy --role-name gha-twinfleet-apply --policy-arn "$arn"
done

echo
echo "================== À REPORTER ==================="
echo "Bucket (backend.tf staging + prod) : $BUCKET"
echo "GitHub > Settings > Secrets and variables > Actions > Variables :"
echo "  AWS_ROLE_PLAN_ARN  = arn:aws:iam::${ACCOUNT_ID}:role/gha-twinfleet-plan"
echo "  AWS_ROLE_APPLY_ARN = arn:aws:iam::${ACCOUNT_ID}:role/gha-twinfleet-apply"
echo "================================================="
