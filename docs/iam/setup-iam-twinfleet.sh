#!/usr/bin/env bash
# =============================================================================
# setup-iam-twinfleet.sh
# Crée le groupe IAM "twinfleet-devs", ses 3 policies personnalisées,
# et les utilisateurs emmanuel + thierno.
# À EXÉCUTER DANS AWS CLOUDSHELL (console AWS > icône >_ en haut), région eu-west-3.
# =============================================================================
set -euo pipefail            # -e : stop à la 1re erreur | -u : variable non définie = erreur | -o pipefail : erreur dans un pipe = erreur
export AWS_PAGER=""          # désactive le pager (sinon la CLI attend "q" après chaque sortie)

GROUP="twinfleet-devs"
USERS=("emmanuel" "thierno")
REGION="eu-west-3"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)   # ID du compte (12 chiffres)
WORKDIR="$HOME/twinfleet-iam"
mkdir -p "$WORKDIR" && cd "$WORKDIR"

echo ">> Compte : $ACCOUNT_ID"

# -----------------------------------------------------------------------------
# 1) Écriture des 3 documents de policy
#    <<'EOF' (guillemets) = bash n'interprète RIEN dedans (indispensable pour ${aws:username})
# -----------------------------------------------------------------------------
cat > iam-roles.json <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ManageTwinfleetRoles",
      "Effect": "Allow",
      "Action": [
        "iam:CreateRole", "iam:DeleteRole", "iam:GetRole", "iam:UpdateRole",
        "iam:TagRole", "iam:UntagRole",
        "iam:ListRolePolicies", "iam:ListAttachedRolePolicies",
        "iam:ListInstanceProfilesForRole"
      ],
      "Resource": "arn:aws:iam::ACCOUNT_ID:role/twinfleet-*"
    },
    {
      "Sid": "AttachOnlyApprovedPolicies",
      "Effect": "Allow",
      "Action": ["iam:AttachRolePolicy", "iam:DetachRolePolicy"],
      "Resource": "arn:aws:iam::ACCOUNT_ID:role/twinfleet-*",
      "Condition": {
        "ArnEquals": {
          "iam:PolicyARN": [
            "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
            "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
          ]
        }
      }
    },
    {
      "Sid": "ManageTwinfleetInstanceProfiles",
      "Effect": "Allow",
      "Action": [
        "iam:CreateInstanceProfile", "iam:DeleteInstanceProfile", "iam:GetInstanceProfile",
        "iam:TagInstanceProfile", "iam:UntagInstanceProfile",
        "iam:AddRoleToInstanceProfile", "iam:RemoveRoleFromInstanceProfile"
      ],
      "Resource": "arn:aws:iam::ACCOUNT_ID:instance-profile/twinfleet-*"
    },
    {
      "Sid": "PassTwinfleetRolesToEC2Only",
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "arn:aws:iam::ACCOUNT_ID:role/twinfleet-*",
      "Condition": { "StringEquals": { "iam:PassedToService": "ec2.amazonaws.com" } }
    },
    {
      "Sid": "ReadManagedPolicies",
      "Effect": "Allow",
      "Action": ["iam:GetPolicy", "iam:GetPolicyVersion", "iam:ListPolicies"],
      "Resource": "*"
    }
  ]
}
EOF
sed -i "s/ACCOUNT_ID/${ACCOUNT_ID}/g" iam-roles.json      # remplace le marqueur par le vrai ID

cat > self-service.json <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ManageOwnCredentials",
      "Effect": "Allow",
      "Action": [
        "iam:GetUser", "iam:ChangePassword", "iam:GetLoginProfile",
        "iam:ListAccessKeys", "iam:CreateAccessKey", "iam:UpdateAccessKey", "iam:DeleteAccessKey",
        "iam:ListMFADevices", "iam:EnableMFADevice", "iam:ResyncMFADevice", "iam:DeactivateMFADevice"
      ],
      "Resource": "arn:aws:iam::*:user/${aws:username}"
    },
    {
      "Sid": "ManageOwnVirtualMFA",
      "Effect": "Allow",
      "Action": ["iam:CreateVirtualMFADevice", "iam:DeleteVirtualMFADevice"],
      "Resource": "arn:aws:iam::*:mfa/*"
    },
    {
      "Sid": "ConsoleDisplay",
      "Effect": "Allow",
      "Action": ["iam:ListVirtualMFADevices", "iam:GetAccountPasswordPolicy", "iam:GetAccountSummary"],
      "Resource": "*"
    }
  ]
}
EOF

cat > guardrails.json <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyOutsideParis",
      "Effect": "Deny",
      "NotAction": [
        "iam:*", "sts:*", "organizations:*", "account:*",
        "budgets:*", "ce:*", "support:*", "health:*", "pricing:*",
        "cloudfront:*", "route53:*", "s3:ListAllMyBuckets", "s3:GetBucketLocation"
      ],
      "Resource": "*",
      "Condition": { "StringNotEquals": { "aws:RequestedRegion": "eu-west-3" } }
    },
    {
      "Sid": "DenyLargeEC2",
      "Effect": "Deny",
      "Action": "ec2:RunInstances",
      "Resource": "arn:aws:ec2:*:*:instance/*",
      "Condition": { "StringNotEquals": { "ec2:InstanceType": ["t3.micro", "t3.small"] } }
    },
    {
      "Sid": "DenyLargeRDS",
      "Effect": "Deny",
      "Action": ["rds:CreateDBInstance", "rds:ModifyDBInstance"],
      "Resource": "*",
      "Condition": {
        "StringNotEquals": { "rds:DatabaseClass": ["db.t3.micro", "db.t4g.micro"] },
        "Null": { "rds:DatabaseClass": "false" }
      }
    },
    {
      "Sid": "DenyMultiAzRDS",
      "Effect": "Deny",
      "Action": ["rds:CreateDBInstance", "rds:ModifyDBInstance"],
      "Resource": "*",
      "Condition": { "Bool": { "rds:MultiAz": "true" } }
    },
    {
      "Sid": "ProtectBudgetAndAudit",
      "Effect": "Deny",
      "Action": ["budgets:ModifyBudget", "cloudtrail:StopLogging", "cloudtrail:DeleteTrail"],
      "Resource": "*"
    }
  ]
}
EOF

# -----------------------------------------------------------------------------
# 2) Création des policies (customer managed)
# -----------------------------------------------------------------------------
create_policy() {   # $1 = nom, $2 = fichier JSON ; affiche l'ARN créé
  aws iam create-policy \
    --policy-name "$1" \
    --policy-document "file://$2" \
    --description "TP TwinFleet - IPSSI" \
    --tags Key=Project,Value=twinfleet \
    --query 'Policy.Arn' --output text
}
ARN_ROLES=$(create_policy TwinFleet-IAM-Roles   iam-roles.json)
ARN_SELF=$(create_policy  TwinFleet-SelfService self-service.json)
ARN_GUARD=$(create_policy TwinFleet-Guardrails  guardrails.json)
echo ">> Policies créées"

# -----------------------------------------------------------------------------
# 3) Groupe + attachement des 4 policies
# -----------------------------------------------------------------------------
aws iam create-group --group-name "$GROUP" > /dev/null
for arn in arn:aws:iam::aws:policy/PowerUserAccess "$ARN_ROLES" "$ARN_SELF" "$ARN_GUARD"; do
  aws iam attach-group-policy --group-name "$GROUP" --policy-arn "$arn"
done
echo ">> Groupe $GROUP prêt"

# -----------------------------------------------------------------------------
# 4) Utilisateurs : création, mot de passe temporaire, ajout au groupe
# -----------------------------------------------------------------------------
echo
echo "================= IDENTIFIANTS (à transmettre par 2 canaux séparés) ================="
echo "URL de connexion : https://${ACCOUNT_ID}.signin.aws.amazon.com/console"
for u in "${USERS[@]}"; do
  aws iam create-user --user-name "$u" --tags Key=Project,Value=twinfleet > /dev/null
  PW="$(openssl rand -base64 18 | tr -d '/+=')Aa1!"          # aléatoire + maj/min/chiffre/symbole pour respecter la politique AWS
  aws iam create-login-profile --user-name "$u" --password "$PW" --password-reset-required > /dev/null
  aws iam add-user-to-group --user-name "$u" --group-name "$GROUP"
  echo "  $u  /  mot de passe temporaire : $PW"
done
echo "======================================================================================"
echo "Pensez à : clear  (pour effacer les mots de passe de l'écran)"
