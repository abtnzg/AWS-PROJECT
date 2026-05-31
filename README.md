# AWS Project - Infrastructure as Code

Multi-environment Terraform infrastructure project avec bootstrap automatisé.

## Structure

```
.
├── bootstrap/                  # Backend infrastructure (S3 + DynamoDB)
│   ├── main.tf
│   ├── provider.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── init.sh
│   └── README.md
├── Terraform-infrastr/         # Environnements de déploiement
│   ├── modules/                # Modules réutilisables
│   │   ├── vpc/
│   │   ├── eks/
│   │   ├── alb/
│   │   ├── acm/
│   │   ├── sg/
│   │   ├── ecr/
│   │   ├── api_gateway/
│   │   └── external_dns/
│   ├── inventories/            # Configuration par environnement
│   │   ├── dev/
│   │   ├── qua/
│   │   ├── rec/
│   │   └── prod/
│   ├── main.tf
│   ├── provider.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── backend.tf
└── .github/
    └── workflows/
        ├── bootstrap.yml       # Workflow bootstrap du backend
        └── terraform.yml       # Workflow déploiement multi-env
```

## Quick Start

### 1️⃣ Bootstrap du backend (une seule fois)

#### Option A : GitHub Actions (recommandé)

1. Va dans **Actions** > **Bootstrap Backend**
2. Clique **Run workflow**
3. Entre `yes` comme confirmation
4. Attends la création du S3 + DynamoDB

#### Option B : Local (si pas de GitHub Actions)

```bash
cd bootstrap
chmod +x init.sh
./init.sh
```

### 2️⃣ Déployer une infrastructure

#### Option A : Via GitHub Actions

1. Va dans **Actions** > **Terraform**
2. Le workflow run automatiquement sur `push` vers `main`
3. Pour appliquer un changement :
   - Clique **Run workflow**
   - Sélectionne l'environnement (`dev`, `qua`, `rec`, `prod`)
   - Active `apply: true`

#### Option B : Local

```bash
cd Terraform-infrastr

# Dev seulement
terraform init -backend-config=inventories/dev/backend.hcl
terraform plan -var-file=inventories/dev/terraform.tfvars
terraform apply -var-file=inventories/dev/terraform.tfvars
```

## Configuration AWS

### Secrets GitHub Actions requis

Ajoute ces secrets dans **Settings** > **Secrets and variables** > **Actions** :

- `AWS_ACCESS_KEY_ID` : clé d'accès AWS
- `AWS_SECRET_ACCESS_KEY` : clé secrète AWS
- `AWS_REGION` : région AWS (ex: `eu-west-3`)

### IAM Policy minimale

Pour que les workflows fonctionnent :

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:*",
        "dynamodb:*",
        "ec2:*",
        "eks:*",
        "iam:*",
        "elasticloadbalancing:*",
        "acm:*",
        "route53:*",
        "ecr:*",
        "apigatewayv2:*"
      ],
      "Resource": "*"
    }
  ]
}
```

## Environnements

### dev
- Développement et tests
- Redéploiement fréquent
- Petites instances

### qua
- Qualification / intégration
- Environnement de test fonctionnel

### rec
- Recette / user acceptance testing
- Config proche de prod

### prod
- Production
- Nécessite approbation manuelle

## Workflows disponibles

### `.github/workflows/bootstrap.yml`

Crée le backend Terraform (S3 + DynamoDB).

**Déclenchement** : Manuel (`workflow_dispatch`)

```bash
# Commande CLI
gh workflow run bootstrap.yml -f confirm=yes
```

### `.github/workflows/terraform.yml`

Déploie l'infrastructure multi-env.

**Déclenchement** :
- `push` vers `main` : lance `plan` pour tous les envs
- `pull_request` vers `main` : lance `plan`
- Manuel : permet de choisir env + `apply`

## Commandes locales utiles

```bash
# Vérifier la syntaxe
terraform fmt -recursive

# Valider
cd Terraform-infrastr
terraform validate

# Plan (dev)
terraform plan -var-file=inventories/dev/terraform.tfvars

# Apply (dev)
terraform apply -var-file=inventories/dev/terraform.tfvars

# Destroy (dev)
terraform destroy -var-file=inventories/dev/terraform.tfvars
```

## Fichiers importants

- `Terraform-infrastr/variables.tf` : variables partagées
- `Terraform-infrastr/provider.tf` : provider AWS (commun)
- `Terraform-infrastr/inventories/<env>/terraform.tfvars` : valeurs par env
- `Terraform-infrastr/inventories/<env>/backend.hcl` : backend S3 par env

## Troubleshooting

### "Backend not initialized"

```bash
cd Terraform-infrastr
terraform init -backend-config=inventories/dev/backend.hcl
```

### "Access Denied" S3/DynamoDB

- Vérifie les secrets GitHub Actions
- Vérifie les permissions IAM
- Assure-toi que le bootstrap a bien créé le bucket

### "State locked"

Une autre opération Terraform est en cours.

```bash
# Voir les locks
aws dynamodb scan --table-name terraform-state-locks

# Forcer déverrous (attention!)
aws dynamodb delete-item --table-name terraform-state-locks \
  --key '{"LockID": {"S": "..."}}' 
```

## Notes supplémentaires

- Le state Terraform est stocké dans S3 avec versioning activé
- Les locks sont gérés par DynamoDB
- Chaque environnement a son propre état S3 separate
- Les modules sont réutilisables

Bon déploiement ! 🚀

