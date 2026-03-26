---
applyTo: "**/*.tf,**/*.tfvars,**/.terraform.lock.hcl"
---

# Terraform コーディングガイドライン

このインストラクションは `.tf`、`.tfvars`、`.terraform.lock.hcl` ファイルに自動適用されます。

---

## 1. ファイル構成標準

```
infra/
├── main.tf                     # リソース定義（ルートモジュール）
├── variables.tf                # 入力変数の定義
├── outputs.tf                  # 出力値の定義
├── locals.tf                   # ローカル値・命名規則・共通タグ
├── backend.tf                  # リモートステート設定
├── versions.tf                 # プロバイダーバージョン制約
├── environments/
│   ├── dev.tfvars              # 開発環境変数値
│   ├── staging.tfvars          # ステージング環境変数値
│   └── prod.tfvars             # 本番環境変数値
└── modules/
    ├── networking/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── identity/
    ├── monitoring/
    └── security/
```

---

## 2. 必須のコーディング規則

### versions.tf（プロバイダーバージョン固定）

```hcl
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
  # サービスプリンシパルではなくマネージド ID / OIDC を使用
  use_oidc = true
}
```

### locals.tf（命名規則の一元管理）

```hcl
locals {
  naming_prefix = "${var.workload_name}-${var.environment_name}"
  location_short = {
    "japaneast"  = "jpe"
    "japanwest"  = "jpw"
    "eastus"     = "eus"
    "westeurope" = "weu"
  }

  common_tags = {
    Environment = var.environment_name
    Workload    = var.workload_name
    ManagedBy   = "Terraform"
    Owner       = var.owner_team
    CostCenter  = var.cost_center_code
  }
}
```

### variables.tf（変数の完全な文書化）

```hcl
variable "environment_name" {
  description = "デプロイ先の環境名"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment_name)
    error_message = "environment_name は 'dev', 'staging', 'prod' のいずれかを指定してください。"
  }
}

variable "workload_name" {
  description = "ワークロード識別子（英数字のみ、2〜10文字）"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]{2,10}$", var.workload_name))
    error_message = "workload_name は英小文字・数字のみ、2〜10文字で指定してください。"
  }
}
```

---

## 3. リモートステート設定（backend.tf）

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state-prod-jpe"
    storage_account_name = "stterraformstateprod001"
    container_name       = "tfstate"
    key                  = "${var.workload_name}/${var.environment_name}/terraform.tfstate"
    # マネージド ID または OIDC を使用（アクセスキーは使わない）
    use_oidc             = true
  }
}
```

---

## 4. セキュリティ必須事項

### シークレット管理

```hcl
# ✅ 推奨: Key Vault データソースを使用
data "azurerm_key_vault" "main" {
  name                = "kv-${local.naming_prefix}-001"
  resource_group_name = azurerm_resource_group.main.name
}

data "azurerm_key_vault_secret" "sql_password" {
  name         = "sql-admin-password"
  key_vault_id = data.azurerm_key_vault.main.id
}

resource "azurerm_mssql_server" "main" {
  name                = "${local.naming_prefix}-sql"
  administrator_login          = "sqladmin"
  administrator_login_password = data.azurerm_key_vault_secret.sql_password.value
}

# ❌ 禁止: .tfvars やコードにシークレットを直接記載
# sql_password = "P@ssw0rd123!"  # 絶対にしない
```

### マネージド ID

```hcl
# ✅ 推奨: ユーザー割り当てマネージド ID
resource "azurerm_user_assigned_identity" "main" {
  name                = "${local.naming_prefix}-identity"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  tags                = local.common_tags
}

# ID を使用するリソースに割り当て
resource "azurerm_linux_function_app" "main" {
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.main.id]
  }
}
```

### 重要リソースの削除保護

```hcl
resource "azurerm_resource_group" "main" {
  name     = "rg-${local.naming_prefix}-${local.location_short[var.location]}"
  location = var.location
  tags     = local.common_tags

  lifecycle {
    prevent_destroy = true  # 本番環境では必須
  }
}
```

### 診断設定

```hcl
resource "azurerm_monitor_diagnostic_setting" "main" {
  name               = "diag-${azurerm_key_vault.main.name}"
  target_resource_id = azurerm_key_vault.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
    retention_policy {
      enabled = true
      days    = 90
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
```

---

## 5. Azure Verified Modules (AVM) の活用

```hcl
# ✅ 推奨: AVM を優先的に使用
module "virtual_network" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "~> 0.4"

  name                = "${local.naming_prefix}-vnet"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  address_space       = [var.vnet_address_space]
  tags                = local.common_tags
}
```

---

## 6. CI/CD 統合パターン

```yaml
# GitHub Actions での Terraform デプロイ
- name: Terraform Plan
  run: |
    terraform init
    terraform plan \
      -var-file="environments/${{ vars.ENVIRONMENT }}.tfvars" \
      -out=tfplan

- name: Terraform Apply
  if: github.ref == 'refs/heads/main'
  run: |
    terraform apply tfplan
```

---

## 7. チェックリスト

デプロイ前に以下を確認してください:

- [ ] `versions.tf` でプロバイダーバージョンが固定されている
- [ ] リモートステートが Azure Storage Account に設定されている
- [ ] すべての変数に `description` と `validation` がある
- [ ] `locals.tf` に命名規則と共通タグが定義されている
- [ ] シークレットは Key Vault データソースまたは環境変数で管理
- [ ] `.tfvars` ファイルにシークレットが含まれていない（`.gitignore` で除外）
- [ ] 重要リソースに `prevent_destroy = true` が設定されている
- [ ] 診断設定が各リソースに設定されている
- [ ] `terraform fmt` と `terraform validate` がパスしている
- [ ] `terraform plan` で変更内容を確認済み
