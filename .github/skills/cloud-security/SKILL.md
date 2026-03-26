# Cloud Security スキル

このスキルファイルは `@cloud-security` エージェントが提供する再利用可能な知識・手順を定義します。

---

## スキル 1: ゼロトラスト 3 原則

| 原則 | 定義 | 実装方法 |
|---|---|---|
| **明示的な検証** | すべてのアクセス要求を継続的に認証・認可する | 条件付きアクセス、MFA、PIM |
| **最小権限アクセス** | 必要最小限の権限のみを付与する | RBAC、JIT アクセス、カスタムロール |
| **侵害の想定** | 侵害を前提とし、横展開を最小化する | ネットワーク分離、監査ログ、SIEM |

---

## スキル 2: Microsoft Defender for Cloud プラン一覧

| プラン | 対象 | 主な機能 |
|---|---|---|
| **Defender for Servers** | VM、Arc サーバー | 脆弱性評価、EDR (MDE)、JIT VM アクセス |
| **Defender for App Service** | App Service | アプリ脅威検出、悪意あるドメイン検出 |
| **Defender for Storage** | Storage Account | マルウェアスキャン、異常アクセス検出 |
| **Defender for SQL** | Azure SQL、SQL VM | SQL インジェクション検出、異常クエリ |
| **Defender for Containers** | AKS、ACR | コンテナイメージスキャン、ランタイム保護 |
| **Defender for Key Vault** | Key Vault | 異常アクセスパターン検出 |
| **Defender for DNS** | Azure DNS | DNS ベースの脅威検出 |
| **Defender for ARM** | Resource Manager | 異常な ARM 操作の検出 |
| **Defender CSPM** | 全リソース | セキュアスコア、攻撃パス分析 |

---

## スキル 3: セキュアスコア改善の優先順位付け

### 評価アプローチ

1. Microsoft Defender for Cloud でセキュアスコアを確認する
2. 「推奨事項」をスコアへの影響度（高→低）でソートする
3. クイックフィックス（数分で対応可能）を優先実施する
4. IaC に組み込み、再発防止する

### 主要なセキュアスコア向上施策

| 推奨事項 | スコア向上効果 | 対応難易度 |
|---|---|---|
| MFA の有効化（全管理者） | 高 | 低 |
| サブスクリプションオーナーを 3 名以下に制限 | 中 | 低 |
| 診断ログの有効化 | 中 | 低（IaC で自動化） |
| JIT VM アクセスの有効化 | 高 | 中 |
| Private Endpoint の採用 | 中 | 中〜高 |
| CMK による暗号化 | 中 | 高 |

---

## スキル 4: Microsoft Sentinel SIEM/SOAR 構成

### アーキテクチャ

```
データソース
    │
    ├── Azure Activity / Resource Logs
    ├── Microsoft Entra ID ログ
    ├── Defender for Cloud アラート
    ├── Defender for Endpoint ログ
    └── サードパーティ（CEF/Syslog）
    │
    ▼
Log Analytics Workspace（Sentinel 有効）
    │
    ├── 分析ルール（検知ロジック）
    │   ├── スケジュール済みクエリ
    │   ├── NRT（ほぼリアルタイム）
    │   └── 異常検知（ML ベース）
    │
    ├── インシデント管理
    │   ├── 優先度付け・トリアージ
    │   └── 調査グラフ
    │
    └── 自動化（SOAR）
        └── プレイブック（Logic Apps）
```

### 重要な分析ルール（有効化推奨）

| ルール | 検知対象 | 重大度 |
|---|---|---|
| Impossible Travel | 地理的に不可能な認証 | 高 |
| Multiple Authentication Failures | ブルートフォース攻撃 | 中〜高 |
| Privileged Identity Protection | 特権アカウントの異常使用 | 高 |
| Anomalous Resource Creation | 異常なリソース作成（クリプトマイニング等） | 高 |
| Exfiltration via DNS | DNS チャネルを用いたデータ持出し | 高 |

---

## スキル 5: セキュリティ KQL クエリ集

### 認証失敗の集計

```kusto
SigninLogs
| where TimeGenerated > ago(1h)
| where ResultType != "0"  // 0 = 成功
| summarize failureCount = count() by UserPrincipalName, IPAddress, ResultDescription
| where failureCount > 10
| order by failureCount desc
```

### 特権ロールの割り当て履歴

```kusto
AuditLogs
| where TimeGenerated > ago(7d)
| where Category == "RoleManagement"
| where OperationName contains "Add member to role"
| extend
    targetUser = tostring(TargetResources[0].userPrincipalName),
    roleName = tostring(TargetResources[0].displayName),
    initiatedBy = tostring(InitiatedBy.user.userPrincipalName)
| project TimeGenerated, initiatedBy, targetUser, roleName, Result
```

### パブリック IP を持つリソースの検出

```kusto
Resources
| where type =~ "microsoft.network/networkinterfaces"
| where isnotnull(properties.ipConfigurations)
| mv-expand ipConfig = properties.ipConfigurations
| where isnotnull(ipConfig.properties.publicIPAddress)
| project id, name, resourceGroup, subscriptionId
```

---

## スキル 6: セキュリティ多層防御（Defense in Depth）

| レイヤー | 保護要素 | Azure サービス |
|---|---|---|
| **ID・アクセス** | MFA、条件付きアクセス、PIM | Microsoft Entra ID |
| **ネットワーク** | NSG、Firewall、DDoS Protection | Azure Firewall、DDoS Standard |
| **コンピュート** | Defender for Servers、EDR、パッチ管理 | Defender for Cloud、Update Manager |
| **アプリケーション** | WAF、API Management、DevSecOps | Azure Front Door WAF、APIM |
| **データ** | 暗号化（保存時・転送時）、Key Vault | Key Vault、SSE、TDE |
| **監視** | SIEM、SOAR、脅威インテリジェンス | Sentinel、Defender for Cloud |

---

*参照エージェント: `@cloud-security`*
*関連スキル: `.github/skills/cloud-governance/SKILL.md`, `.github/skills/cloud-operations/SKILL.md`*
