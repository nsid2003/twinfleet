# State distant : un seul bucket, une clé (chemin) par environnement.
#  - bucket       : nom affiché par docs/iam/setup-ci-oidc.sh
#  - key          : chemin du state dans le bucket => staging et prod totalement séparés
#  - encrypt      : chiffrement côté serveur du fichier de state
#  - use_lockfile : verrou .tflock dans S3 => deux apply simultanés impossibles (Terraform >= 1.10)
terraform {
  backend "s3" {
    bucket       = "twinfleet-tfstate-370a93b2"
    key          = "staging/terraform.tfstate"
    region       = "eu-west-3"
    encrypt      = true
    use_lockfile = true
  }
}
