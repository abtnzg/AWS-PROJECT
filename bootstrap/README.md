# Terraform Backend Bootstrap

Ce dossier contient la configuration Terraform pour créer automatiquement les ressources du backend (S3 + DynamoDB).

## Prérequis

- `terraform` >= 1.5.0
- `aws-cli` configuré avec les bonnes credentials
- Permissions IAM pour créer S3 buckets et DynamoDB tables

## Utilisation

### Option 1 : Script automatisé (recommandé)

```bash
cd bootstrap
chmod +x init.sh
./init.sh
```

Le script :
1. Vérifie les prérequis (terraform, aws-cli, credentials)
2. Initialise Terraform en local
3. Affiche le plan
4. Demande confirmation avant de créer
5. Crée S3 + DynamoDB

### Option 2 : Commandes Terraform manuelles

```bash
cd bootstrap
terraform init
terraform plan
terraform apply
```

## Ressources créées

- **S3 Bucket** : `aws-project-terraform-state`
  - Versioning activé
  - Chiffrement AES256
  - Accès public bloqué

- **DynamoDB Table** : `terraform-state-locks`
  - Facturation à l'usage (pay-per-request)
  - Clé primaire : `LockID`

## Variables

Modifiables dans `variables.tf` ou via `-var` :

- `aws_region` : région AWS (défaut: `eu-west-3`)
- `state_bucket_name` : nom du bucket S3 (défaut: `aws-project-terraform-state`)
- `locks_table_name` : nom de la table DynamoDB (défaut: `terraform-state-locks`)
- `tags` : tags AWS à appliquer

## Après le bootstrap

Une fois le backend créé, tu peux lancer :

```bash
cd ../Terraform-infrastr
terraform init -backend-config=inventories/dev/backend.hcl
```

Et ensuite utiliser Terraform normalement avec le state stocké dans S3.

## Nettoyage

Pour détruire les ressources du backend :

```bash
cd bootstrap
terraform destroy
```

⚠️ **Attention** : cela supprimera le bucket S3 et la table DynamoDB. Assure-toi que le state n'est plus utilisé.
