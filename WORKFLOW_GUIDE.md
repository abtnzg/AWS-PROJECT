# Terraform Destroy & Apply Workflow

## 📋 Utilisation

Ce workflow GitHub Actions permet de nettoyer et recréer les ressources AWS après des erreurs d'état Terraform.

### 🚀 Lancer le workflow

1. Allez à **Actions** → **Terraform Destroy & Apply**
2. Cliquez sur **Run workflow**
3. Sélectionnez les paramètres :
   - **environment** : `dev` (ou `qua`, `rec`, `prod`)
   - **action** :
     - `plan-only` : Voir les changements sans appliquer
     - `apply` : Appliquer les changements (création seulement)
     - `destroy` : Détruire puis recréer toutes les ressources

### ⚠️ Actions disponibles

| Action | Description | Quand l'utiliser |
|--------|-------------|------------------|
| `plan-only` | Affiche le plan sans l'appliquer | Avant de faire des changements |
| `apply` | Crée les ressources manquantes | Pour créer/mettre à jour normalement |
| `destroy` | Supprime PUIS recrée tout | Après un `terraform apply` partiellement échoué |

### 🔄 Scénario : Corriger l'état Terraform actuel

**Problème actuel :**
```
Error: ELBv2 Load Balancer (aws-project-alb-dev) already exists
Error: ELBv2 Target Group (aws-project-alb-dev-tg) already exists
Error: IAM Role (aws-project-eks-dev-cluster-role) already exists
```

**Solution :**
1. Allez à **GitHub Actions**
2. Sélectionnez **Terraform Destroy & Apply**
3. Remplissez le formulaire :
   - Environment: `dev`
   - Action: `destroy`
4. Cliquez sur **Run workflow**
5. Le workflow va :
   - Détruire toutes les ressources
   - Attendre ~5 minutes
   - Recréer les ressources depuis zéro

### ✅ Monitoring

- Regardez les logs dans l'onglet **Actions**
- Les plans Terraform sont disponibles en téléchargement (artifacts)
- Les erreurs s'affichent en rouge dans les logs

### 🔐 Prérequis

- ✅ `AWS_ROLE_ARN` doit être configuré dans les secrets GitHub
- ✅ Le backend S3 doit être accessible
- ✅ L'utilisateur IAM doit avoir les permissions nécessaires

---

## 📌 Notes

- Le workflow utilise `terraform workspace` pour isoler les environnements
- Les variable files sont chargées depuis `inventories/{environment}/terraform.tfvars`
- Les artifacts (plans) sont conservés 7 jours

