# GitHub Copilot ベースラインルール — CAF Agents リポジトリ

このファイルはリポジトリ全体に適用されるベースラインルールを定義します。
各エージェント固有の指示は `.github/agents/{name}.agent.md` に記述してください。
エージェントの指示がこのファイルと矛盾する場合は、エージェント固有の指示が優先されます。

---

## 1. リポジトリの目的と構成

このリポジトリは **Azure Cloud Adoption Framework (CAF)** に基づくマルチエージェント協調システムを提供します。

### エージェント体系

| エージェント | 役割 | ファイル |
|---|---|---|
| `@cloud-strategy` | クラウド戦略・ビジネスケース策定 | `.github/agents/cloud-strategy.agent.md` |
| `@cloud-governance` | ガバナンス・ポリシー・コンプライアンス | `.github/agents/cloud-governance.agent.md` |
| `@cloud-platform` | Landing Zone・IaC・基盤構築 | `.github/agents/cloud-platform.agent.md` |
| `@cloud-operations` | 監視・インシデント対応・SLO 管理 | `.github/agents/cloud-operations.agent.md` |
| `@cloud-security` | セキュリティ・ゼロトラスト・脅威対応 | `.github/agents/cloud-security.agent.md` |
| `@ccoe` | 全チーム統合・標準化・セルフサービス | `.github/agents/ccoe.agent.md` |
| `@copilot-expert` | `.agent.md` フォーマット評価 | `.github/agents/copilot-expert.agent.md` |
| `@hr-evaluation` | エージェント品質評価（CAF 準拠） | `.github/agents/hr-evaluation.agent.md` |

---

## 2. 共通の言語・スタイル規則

- **主要言語**: 日本語（技術用語・固有名詞は英語のまま使用）
- **敬体 / 常体**: エージェントへの指示は常体（「〜する」「〜である」）で統一
- **見出し**: マークダウン `##` / `###` で論理的に構造化する
- **コードブロック**: 言語指定を必ず付与する（`bicep`, `hcl`, `json`, `kusto`, `yaml` 等）
- **表形式**: 比較・一覧情報は可能な限りテーブルで整理する

---

## 3. Azure CAF 共通用語・概念

以下の用語は全エージェントで統一して使用します。

### 管理グループ・リソース階層

```
テナントルートグループ
└── 組織ルート
    ├── Platform（プラットフォーム）
    │   ├── Management
    │   ├── Connectivity
    │   └── Identity
    ├── Landing Zones
    │   ├── Corp
    │   └── Online
    ├── Sandbox
    └── Decommissioned
```

### 命名規則（デフォルト）

| リソース種別 | 命名パターン | 例 |
|---|---|---|
| リソースグループ | `rg-{workload}-{env}-{region}` | `rg-webapp-prod-jpe` |
| 仮想ネットワーク | `vnet-{workload}-{env}-{region}` | `vnet-hub-prod-jpe` |
| Key Vault | `kv-{workload}-{env}-{suffix}` | `kv-app-prod-001` |
| Log Analytics | `law-{purpose}-{env}-{region}` | `law-platform-prod-jpe` |
| ストレージアカウント | `st{workload}{env}{suffix}` | `stapprod001` |

### タグ戦略（必須タグ）

| タグ名 | 説明 | 例 |
|---|---|---|
| `Environment` | 環境 | `dev` / `staging` / `prod` |
| `Workload` | ワークロード識別子 | `webapp` / `dataplatform` |
| `CostCenter` | コストセンターコード | `CC-1234` |
| `Owner` | 担当チーム / 個人 | `platform-team` |
| `ManagedBy` | 管理方法 | `Bicep` / `Terraform` / `Manual` |

### リージョン略称

| Azure リージョン | 略称 |
|---|---|
| Japan East | `jpe` |
| Japan West | `jpw` |
| East US | `eus` |
| West Europe | `weu` |

---

## 4. IaC 共通ルール

詳細は `.github/instructions/bicep.instructions.md` および `.github/instructions/terraform.instructions.md` を参照してください。

### Bicep 基本方針

- エントリポイントは `main.bicep`（または `main.bicepparam`）
- パラメータはデコレータ（`@description`, `@allowed`, `@minLength`）で文書化
- モジュール分割: リソース種別ごとに `modules/` 配下にサブディレクトリを作成
- シークレットは Key Vault 参照（`getSecret()`）を使用。コードにハードコードしない

### Terraform 基本方針

- `versions.tf` でプロバイダーバージョンを固定（`~> 4.0` 等）
- リモートステートは Azure Storage Account を使用
- `locals.tf` に命名規則・共通タグを集約
- Azure Verified Modules (AVM) を優先的に活用

---

## 5. セキュリティ共通方針

すべてのエージェントはセキュリティに関して以下の方針を遵守します。

### 最小権限の原則
- サービスプリンシパルよりも **マネージド ID** を優先する
- RBAC ロールは必要最小限のスコープ・権限で割り当てる
- `Owner` / `Contributor` ロールの直接割り当ては極力避け、カスタムロールを検討する

### シークレット管理
- パスワード・APIキー・証明書は **Azure Key Vault** で集中管理する
- IaC コード内へのシークレットのハードコードは禁止
- `.env` ファイル等のシークレットを含むファイルは Git にコミットしない

### 暗号化
- 保存時暗号化: Azure Storage Service Encryption (SSE)、Transparent Data Encryption (TDE) を標準適用
- 転送時暗号化: TLS 1.2 以上を必須とする
- カスタマーマネージドキー (CMK) は規制要件や高機密データに適用を検討

### 監査ログ
- Azure Monitor 診断設定をすべてのリソースで有効化する
- Log Analytics Workspace にログを集約する
- 保持期間: 最低 90 日間（規制要件がある場合はそれに従う）

---

## 6. エージェント間連携の基本ルール

### エスカレーションパス

```
質問・タスク
    │
    ├─ 戦略・ビジネスケース → @cloud-strategy
    ├─ ポリシー・コンプライアンス → @cloud-governance
    ├─ Landing Zone・IaC → @cloud-platform
    ├─ 監視・運用・SLO → @cloud-operations
    ├─ セキュリティ・ゼロトラスト → @cloud-security
    └─ 全体統合・調整 → @ccoe
```

### 情報共有のルール

- 他エージェントへの依頼事項は `@{エージェント名}` で明示する
- RACI マトリックスで責任分担を明確化する（**R**: 実行責任, **A**: 説明責任, **C**: 相談先, **I**: 報告先）
- 共通の成果物（ポリシー定義、IaC テンプレート等）は一元管理し、参照で連携する

---

## 7. エージェント品質基準

`.github/agents/` 配下の `.agent.md` ファイルは以下の品質基準を満たすこと。

### 必須要素（フォーマット）

```yaml
---
name: {agent-name}           # ファイル名と一致すること
description: {description}   # 50〜200文字、トリガーキーワードを含む
tools:
  - {tool}                   # 役割に必要な最小限のツール
# mcp-servers は必要な場合のみ記述
---
```

### 推奨セクション構成

1. `# {Agent Name} エージェント` - タイトルと概要
2. `## 基本原則` - エージェントの行動指針（3〜5 箇条）
3. `## 主要活動領域` - 具体的な業務内容と手順
4. `## ⚠️ 対応範囲と制約` - やらないこと、スコープ外の定義
5. `## 他エージェントとの連携` - 連携マトリックスとシナリオ
6. `## 💬 使用例` - ユーザー入力例と期待する出力例
7. `## 回答時のガイドライン` - 回答品質を保つためのルール

### 評価基準（copilot-expert フレームワーク、35 点満点）

| 観点 | 配点 | 合格ライン |
|---|---|---|
| フォーマット準拠度 | 5 | 4 以上 |
| description の品質 | 5 | 4 以上 |
| ツールの最小権限 | 5 | 3 以上 |
| バウンダリ定義 | 5 | 3 以上 |
| 具体例の有無 | 5 | 3 以上 |
| Agent Skills 連携 | 5 | 3 以上 |
| Custom Instructions 活用 | 5 | 3 以上 |
| **合計** | **35** | **28 以上** |

詳細評価フレームワークは `@copilot-expert` または `@hr-evaluation` に依頼してください。

---

## 8. スキルファイルの管理

`.github/skills/{agent-name}/SKILL.md` に各エージェントの再利用可能なスキルを定義します。

- **粒度**: 単一の明確な目的を持つ手順・知識
- **再利用性**: 複数エージェントで共通して参照できる内容はこちらで定義
- **参照方法**: エージェント本文から `参照: .github/skills/{name}/SKILL.md` の形式でリンク

---

## 9. プロンプトファイルの管理

`.github/prompts/` 配下に繰り返し使用するプロンプトテンプレートを配置します。

| ファイル | 用途 |
|---|---|
| `agent-review.prompt.md` | エージェント品質評価の標準プロンプト |

---

*最終更新: 2026-03-25*
