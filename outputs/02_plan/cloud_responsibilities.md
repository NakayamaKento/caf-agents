# クラウド責任計画書（Cloud Responsibilities Plan）
## Azure CAF 計画フェーズ（Plan Methodology）- ステップ 3

**文書バージョン**: 1.0  
**作成日**: 2026年4月12日  
**作成チーム**: @cloud-governance（主幹）  
**統合チーム**: @cloud-governance / @cloud-security / @cloud-operations / @cloud-platform  
**ステータス**: 承認済み  
**関連成果物**: `operating_model.md` / `cloud_adoption_experience.md` / `strategy_assessment.md`

---

## 目次

1. [エグゼクティブサマリー](#1-エグゼクティブサマリー)
2. [ガバナンス責任の計画（@cloud-governance）](#2-ガバナンス責任の計画cloud-governance)
3. [セキュリティ責任の計画（@cloud-security）](#3-セキュリティ責任の計画cloud-security)
4. [管理責任の計画（@cloud-operations）](#4-管理責任の計画cloud-operations)
5. [AI 導入責任の計画（@cloud-platform）](#5-ai-導入責任の計画cloud-platform)
6. [統合 RACI マトリックス](#6-統合-raci-マトリックス)
7. [責任境界の定義](#7-責任境界の定義)
8. [フェーズ別責任の変化](#8-フェーズ別責任の変化)

---

## 1. エグゼクティブサマリー

### 1.1 責任計画の目的と背景

本文書は、Azure Cloud Adoption Framework（CAF）計画フェーズ（Plan Methodology）の**ステップ 3「クラウド責任計画の策定」**として策定されます。

戦略フェーズで確立した組織評価（総合スコア 2.6/5.0）および計画フェーズのステップ 1「導入体験マッピング」・ステップ 2「運用モデル定義」の成果を踏まえ、**@cloud-governance・@cloud-security・@cloud-operations・@cloud-platform の 4 チームが担うべき責任領域を明確化**します。

クラウド環境では、責任の曖昧さが最大のリスク要因のひとつです。「誰が・何を・いつまでに・どのレベルで」行う責任を持つかを本計画書で明文化することで、インシデントの未検知・コンプライアンス違反・コスト超過を防ぎます。

### 1.2 本計画書が解決する課題

| 課題 | 現状のリスク | 本計画書による解決策 |
|---|---|---|
| **責任の空白（Accountability Gap）** | 複数チームの境界領域でインシデントが放置される | RACI マトリックスで Accountable を一点に定める |
| **ガバナンスと開発速度のトレードオフ** | 強制ポリシーが開発チームの自律性を損なう | 段階的ガードレール（Audit → Deny）で自律性を確保 |
| **コンプライアンス対応の遅れ** | 個人情報保護法改正（2026/6）・ISMAP・PCI DSS v4.0 への不適合 | 各チームのコンプライアンス責任を期日付きで割り当て |
| **コスト可視性の欠如** | クラウド支出が管理不能になるリスク | FinOps 責任をガバナンスチームに集約し、FinOps フレームワーク適用 |
| **インシデント対応の属人化** | 担当者不在時の対応漏れ | 運用チームに Runbook・エスカレーションパスを整備 |

### 1.3 4 チームの責任領域マップ

```
┌──────────────────────────────────────────────────────────────────────┐
│                    組織のクラウド環境                                    │
│                                                                      │
│  ┌─────────────────────┐   ┌──────────────────────────────────────┐  │
│  │  @cloud-governance  │   │         @cloud-platform              │  │
│  │  ポリシー・コスト管理  │   │  Landing Zone・AI 基盤・インフラ管理   │  │
│  │  コンプライアンス監視  │   │  物理 120台 + VM 280台              │  │
│  └──────────┬──────────┘   └────────────────────┬─────────────────┘  │
│             │ ガードレール提供                    │ 基盤提供             │
│  ┌──────────▼──────────┐   ┌────────────────────▼─────────────────┐  │
│  │  @cloud-security    │   │         @cloud-operations            │  │
│  │  ゼロトラスト実装    │   │  監視・インシデント対応・SLO 管理      │  │
│  │  脅威検出・CSPM     │   │  パッチ・変更管理・Runbook 整備        │  │
│  └─────────────────────┘   └──────────────────────────────────────┘  │
│                                                                      │
│  ▶ クロスチームの統括責任: CCoE（Cloud Center of Excellence）           │
└──────────────────────────────────────────────────────────────────────┘
```

### 1.4 現状と目標の対比

| 評価軸 | 現状 | 本計画完了後の目標 | 達成期限 |
|---|---|---|---|
| ガバナンス成熟度 | Level 2（管理済み） | Level 4（測定） | 2027年9月 |
| セキュリティインシデント対応時間 | 72 時間 | 4 時間 | 2027年3月 |
| 可用性 | 99.5% | 99.95% | 2027年3月 |
| FinOps 成熟度 | Crawl（手動） | Walk → Run（自動化） | 2027年9月 |
| Azure Policy 適用率 | 部分的 Audit | 全領域 Deny（本番） | 2027年3月 |
| AI 活用ワークロード数 | 0 | 3 以上 | 2027年9月 |

---

## 2. ガバナンス責任の計画（@cloud-governance）

### 2.1 責任領域の概要

@cloud-governance チームは、**組織全体のクラウドリスクを管理し、ビジネス目標達成を技術的統制で支援する**責任を担います。ガバナンスはゲートキーパーではなくイネーブラーとして機能し、開発チームの自律性を損なわないガードレール設計を原則とします。

> **リスク許容度の定義**: リスク許容度は @cloud-strategy チームが定義するビジネス目標と整合させ、四半期ごとに共同レビューします。本計画書の設定値は初期値であり、2026年7月・10月・2027年1月のレビューを経て更新します。

---

### 2.2 ポリシー管理責任

#### 2.2.1 責任の定義

| 責任項目 | 詳細 | 優先度 | 完了期限 |
|---|---|---|---|
| ポリシー設計 | Azure Policy 定義・イニシアティブの設計（Bicep/Terraform） | 最高 | 2026年6月 |
| ポリシー適用 | 管理グループ階層へのポリシー割り当て | 最高 | 2026年6月 |
| ポリシー変更管理 | ポリシー変更の影響評価・承認プロセスの運用 | 高 | 2026年7月 |
| 例外申請管理 | ポリシー例外の審査・承認・期限管理 | 高 | 継続 |
| ポリシー as Code | Git リポジトリでのポリシー定義管理（CI/CD 統合） | 中 | 2026年9月 |

#### 2.2.2 Azure Policy 5 段階適用計画

```
フェーズ 0（〜2026/6）  : 全ポリシーを Audit モードで適用・違反状況の把握
フェーズ 1（2026/7-9） : コスト管理ポリシーを Deny に移行（VM SKU制限・タグ必須化）
フェーズ 2（2026/10-12）: セキュリティベースラインを Deny に移行（HTTPS強制・パブリックIP制限）
フェーズ 3（2027/1-3） : リソース整合性・ID ベースラインを Deny に移行
フェーズ 4（2027/4-）  : 全ポリシー Deny モード完成・自動修復（DINE/Modify）の適用
```

> ⚠️ **Deny 移行前の必須アクション**: 各フェーズの Deny 移行前に、@cloud-platform・@cloud-operations・ワークロードチームへ 2 週間以上前に通知し、影響を受けるリソースのリストを共有します。移行後 2 週間は例外申請を優先審査します。

#### 2.2.3 推奨 Azure Policy（優先適用）

**コスト管理**
- `Allowed virtual machine size SKUs` — 承認済み VM SKU のみ許可
- `Require a tag and its value on resources` — CostCenter・環境・部門タグの強制
- `Inherit a tag from the resource group` — リソースグループタグの自動継承

**セキュリティ**
- `Microsoft cloud security benchmark` イニシアティブ — セキュリティベースライン一括適用
- `Secure transfer to storage accounts should be enabled` — HTTPS 通信の強制
- `Network interfaces should not have public IPs` — パブリック IP 直接割り当ての制限

**リソース整合性**
- `Allowed locations` — 東日本・西日本リージョンのみ許可（データ主権対応）
- `Azure Backup should be enabled for Virtual Machines` — VM バックアップの強制

**ID 管理**
- `MFA should be enabled for accounts with owner permissions` — オーナー MFA 強制
- `A maximum of 3 owners should be designated for your subscription` — オーナー数制限

#### 2.2.4 例外申請プロセス

```
申請者（ワークロードチーム）
    │
    ▼
例外申請フォーム記入（理由・期限・代替コントロールを必須記載）
    │
    ▼
@cloud-governance レビュー（SLA: 3営業日以内）
    │
    ├── 承認 → Policy Exemption リソースを IaC で作成・期限付き設定
    │
    └── 非承認 → 代替コントロールの提案（条件付き承認も可）

※ 月間例外申請数が 20 件超の場合 → ポリシー妥当性レビューを実施
```

---

### 2.3 コンプライアンス管理責任

#### 2.3.1 対応する規制要件と責任割り当て

| 規制要件 | 対応期限 | 主責任チーム | 支援チーム | 主な対応内容 |
|---|---|---|---|---|
| **個人情報保護法改正** | 2026年6月 | @cloud-governance | @cloud-security | データ分類ポリシー・アクセスログ保全 |
| **ISMAP 認定維持** | 継続 | @cloud-governance | @cloud-security, @cloud-operations | 年次監査対応・証跡管理 |
| **ISO 27001 拡大** | 2026年12月 | @cloud-governance | 全チーム | 情報資産管理・リスクアセスメント更新 |
| **PCI DSS v4.0** | 2025年3月（移行済み） | @cloud-governance | @cloud-security | カード会員データ環境の分離・監査ログ |

#### 2.3.2 コンプライアンス監視の仕組み

```kusto
// 週次コンプライアンスレポート（Log Analytics）
PolicyStates
| where TimeGenerated > ago(7d)
| where ComplianceState == "NonCompliant"
| summarize
    nonCompliantCount = dcount(ResourceId),
    latestTimestamp = max(TimeGenerated)
    by PolicyDefinitionName, PolicyDefinitionAction, SubscriptionId
| order by nonCompliantCount desc
| project-rename
    ポリシー名 = PolicyDefinitionName,
    アクション = PolicyDefinitionAction,
    サブスクリプション = SubscriptionId,
    非準拠リソース数 = nonCompliantCount
```

- **週次**: コンプライアンスダッシュボード確認・非準拠リソースの担当チームへの通知
- **月次**: コンプライアンスレポート作成・経営層への報告
- **四半期**: 外部監査対応・リスクアセスメント更新

---

### 2.4 コスト管理（FinOps）責任

#### 2.4.1 FinOps 成熟度ロードマップ

| フェーズ | 期間 | 主な取り組み | 目標指標 |
|---|---|---|---|
| **Crawl（現在）** | ～2026年6月 | コスト可視化・タグ戦略整備・予算アラート設定 | 全リソースにタグ 100% 付与 |
| **Walk** | 2026年7月〜2026年12月 | 部門別チャージバック・Reserved Instances 活用・自動シャットダウン | コスト予測精度 ±10% 以内 |
| **Run** | 2027年1月〜 | 自動最適化・AIによる異常検知・Savings Plans の動的適用 | 無駄コスト 20% 削減 |

#### 2.4.2 コスト管理の具体的責任

- **予算設定**: サブスクリプション・リソースグループ単位での予算作成と Azure Cost Management 連携
- **アラート管理**: 予算の 70%・90%・100% での通知設定（担当: @cloud-governance）
- **タグ戦略**: `CostCenter`・`Environment`・`Department`・`Owner`・`Project` の 5 タグを必須化
- **月次レビュー**: FinOps レビュー会議の主催（参加: 各チームリード・@cloud-strategy）
- **最適化勧告**: Azure Advisor のコスト推奨事項を月次でレビューし改善アクションを割り当て

---

### 2.5 リスク管理責任

#### 2.5.1 リスク評価フレームワーク

| リスクカテゴリ | リスク許容度 | 検出方法 | エスカレーション先 |
|---|---|---|---|
| コスト超過（予算の 20% 超） | 低（即時対応） | Azure Cost Management アラート | @cloud-strategy CFO |
| セキュリティ侵害 | ゼロトレランス | Defender for Cloud・Sentinel | @cloud-security CISO |
| コンプライアンス違反 | 低（48時間以内対応） | Policy 非準拠アラート | @cloud-governance リード |
| 可用性 SLA 違反 | 中（計画的対応） | Azure Monitor アラート | @cloud-operations |
| 技術的負債 | 中（段階的対応） | Resource Graph 棚卸し | @cloud-platform |

#### 2.5.2 リスク管理サイクル

```
月次リスクアセスメント
    → リスクレジスター更新（@cloud-governance 主導）
    → リスクオーナーへのアクション割り当て
    → 四半期レビューで @cloud-strategy に報告
    → 年次: ISO 27001 リスクアセスメント更新
```

---

## 3. セキュリティ責任の計画（@cloud-security）

### 3.1 責任領域の概要

@cloud-security チームは、**組織のクラウド環境におけるセキュリティ体制の設計・実装・監視・改善**を担います。ゼロトラストアーキテクチャへの移行を最高優先事項として位置付け、Microsoft Defender for Cloud による CSPM（Cloud Security Posture Management）の継続的な運用が中心業務です。

---

### 3.2 ゼロトラスト実装責任

#### 3.2.1 ゼロトラスト移行ロードマップ

```
フェーズ 0（〜2026/6）: 現状評価・アーキテクチャ設計
  ├── 現行ネットワーク境界防御の棚卸し
  ├── ID・デバイス・アプリ・データの信頼モデル設計
  └── Microsoft Entra ID 条件付きアクセスの基盤整備

フェーズ 1（2026/7-12）: ID・デバイスのゼロトラスト化
  ├── PIM（Privileged Identity Management）の全特権アカウントへの適用
  ├── デバイスコンプライアンスポリシーの強制
  ├── Microsoft Defender for Endpoint の全デバイス展開
  └── Multi-Factor Authentication の全ユーザー強制

フェーズ 2（2027/1-6）: ネットワーク・アプリのゼロトラスト化
  ├── Hub-Spoke ネットワークトポロジへの移行
  ├── プライベートエンドポイントによるパブリックアクセス遮断
  ├── Azure Firewall Premium による East-West トラフィック制御
  └── マイクロセグメンテーションの実装

フェーズ 3（2027/7-）: データ・継続改善
  ├── Microsoft Purview によるデータ分類・保護
  ├── Insider Risk Management の導入
  └── 継続的な脅威モデリング
```

#### 3.2.2 ゼロトラスト実装の責任分担

| 実装領域 | @cloud-security | @cloud-platform | @cloud-governance | @cloud-operations |
|---|---|---|---|---|
| ID（Entra ID PIM） | **R/A** | C | C | I |
| デバイス（Defender for Endpoint） | **R/A** | C | I | C |
| ネットワーク（Hub-Spoke, Firewall） | **A** | **R** | C | C |
| アプリケーション（Private Endpoint） | **A** | **R** | C | I |
| データ（Purview） | **R/A** | C | C | I |

---

### 3.3 脅威検出・対応責任

#### 3.3.1 Microsoft Defender for Cloud 導入責任

| Defender プラン | 対象リソース | 導入期限 | 担当 |
|---|---|---|---|
| Defender for Servers | 全 VM（280台） | 2026年6月 | @cloud-security |
| Defender for Storage | 全ストレージアカウント | 2026年6月 | @cloud-security |
| Defender for SQL | 全 SQL Database | 2026年7月 | @cloud-security |
| Defender for Containers | AKS クラスター | 2026年9月 | @cloud-security |
| Defender for App Service | Web App Service | 2026年9月 | @cloud-security |
| Defender CSPM（強化プラン） | サブスクリプション全体 | 2026年6月 | @cloud-security |

#### 3.3.2 インシデント対応 SLA 目標

| インシデント重大度 | 検出目標 | 初動対応目標 | 封じ込め目標 | 担当 |
|---|---|---|---|---|
| **Critical（P1）** | 5 分以内 | 15 分以内 | 4 時間以内 | @cloud-security CISO + SOC |
| **High（P2）** | 15 分以内 | 1 時間以内 | 24 時間以内 | @cloud-security SOC |
| **Medium（P3）** | 1 時間以内 | 4 時間以内 | 72 時間以内 | @cloud-security SOC |
| **Low（P4）** | 4 時間以内 | 1 営業日以内 | 1 週間以内 | @cloud-security エンジニア |

> **現状から目標への改善**: 現在の重大インシデント対応時間 72 時間を 2027年3月までに 4 時間に短縮するため、Microsoft Sentinel による SOAR（Security Orchestration Automated Response）の自動化を 2026年9月までに実装します。

#### 3.3.3 SIEM/SOAR 実装責任（Microsoft Sentinel）

```
@cloud-security の責任:
  ├── Sentinel ワークスペースの設計・構成
  ├── データコネクタの接続（Azure AD, Defender, Office 365 等）
  ├── 分析ルールの作成・チューニング
  ├── Playbook（Logic Apps）による自動対応の実装
  ├── インシデント管理プロセスの定義
  └── SOC アナリストのトレーニング

@cloud-operations との連携:
  ├── Log Analytics Workspace の共同管理
  ├── アラートのエスカレーションパス定義
  └── Runbook との連携（セキュリティ対応の自動化）
```

---

### 3.4 コンプライアンス・監査責任

#### 3.4.1 セキュリティ監査責任

| 監査活動 | 頻度 | 主責任 | 証跡保管期間 | 保管場所 |
|---|---|---|---|---|
| Azure アクティビティログ収集 | 継続 | @cloud-security | 1年（規制要件: 最低 90日） | Log Analytics Workspace |
| 特権アクセスレビュー | 四半期 | @cloud-security | 5年 | Azure Archive Storage |
| ペネトレーションテスト | 年次 | @cloud-security（外部委託可） | 5年 | セキュリティ管理システム |
| セキュリティスコアレビュー | 月次 | @cloud-security | 1年 | Defender for Cloud |
| ISMAP 証跡提出 | 年次 | @cloud-security + @cloud-governance | 5年 | 専用ストレージ |

#### 3.4.2 ISMAP 認定維持責任

- **主責任**: @cloud-governance（コンプライアンス全体統括）+ @cloud-security（技術統制証跡）
- **対応期限**: 年次認定更新（次回: 2026年11月）
- **証跡管理**: Microsoft Defender for Cloud + Log Analytics による自動証跡収集
- **外部審査対応**: @cloud-governance が審査スケジュールを管理し、各チームへ証跡提出依頼

---

### 3.5 セキュリティ教育責任

| 対象 | 内容 | 頻度 | 担当 |
|---|---|---|---|
| 全組織員 | セキュリティ意識向上（フィッシング・ソーシャルエンジニアリング） | 年 2 回 | @cloud-security |
| クラウドエンジニア | Azure セキュリティベストプラクティス・ゼロトラスト設計 | 半期 | @cloud-security |
| 開発チーム | DevSecOps・シフトレフトセキュリティ | 四半期 | @cloud-security + CCoE |
| 管理者・特権ユーザー | 特権アクセス管理・PIM 操作 | 年次 | @cloud-security |

---

## 4. 管理責任の計画（@cloud-operations）

### 4.1 責任領域の概要

@cloud-operations チームは、**クラウド環境の日常的な運用・監視・インシデント対応・変更管理**を担います。運用成熟度 2.5/5.0 の現状から、2027年9月までに 4.0/5.0 への向上を目標とします。Log Analytics Workspace の構築から始め、SLO 管理・Runbook 整備・自動化の段階的な実現を責任として担います。

---

### 4.2 監視・可観測性責任

#### 4.2.1 監視基盤の整備責任

| コンポーネント | 担当 | 完了期限 | 優先度 |
|---|---|---|---|
| Log Analytics Workspace 設計・構築 | @cloud-operations + @cloud-platform | 2026年6月 | 最高 |
| Azure Monitor アラートルール設定 | @cloud-operations | 2026年7月 | 最高 |
| Application Insights 展開 | @cloud-operations + ワークロードチーム | 2026年7月 | 高 |
| Azure Monitor Workbooks（ダッシュボード） | @cloud-operations | 2026年9月 | 高 |
| 分散トレーシング（Application Map） | @cloud-operations + 開発チーム | 2026年10月 | 中 |
| AI Ops（異常検知の自動化） | @cloud-operations | 2027年3月 | 中 |

#### 4.2.2 Log Analytics Workspace 設計原則

```
ワークスペース設計:
  ├── ワークスペース数: 環境別（本番/非本番）× 目的別（セキュリティ/運用）= 最大 4
  ├── データ保持期間: 90日（インタラクティブ）+ 730日（アーカイブ）
  ├── アクセス制御: リソース別アクセスモード（ワークロードチームは自リソースのみ参照可）
  └── コスト管理: コミットメントティアの月次レビュー（@cloud-governance と共同）

データソース:
  ├── Azure Activity Log（全サブスクリプション）
  ├── Azure Diagnostics（VM・PaaS リソース）
  ├── Microsoft Defender for Cloud
  ├── Microsoft Sentinel（セキュリティ専用ワークスペース）
  └── Application Insights（アプリケーションテレメトリ）
```

#### 4.2.3 監視責任の範囲

| 監視対象 | 担当チーム | 使用ツール | アラート通知先 |
|---|---|---|---|
| インフラ（VM・ネットワーク） | @cloud-operations | Azure Monitor | @cloud-operations オンコール |
| 物理サーバー（120台） | @cloud-platform + @cloud-operations | Azure Arc + Monitor | @cloud-operations |
| セキュリティイベント | @cloud-security | Microsoft Sentinel | @cloud-security SOC |
| アプリケーション | ワークロードチーム | Application Insights | 各ワークロードチーム |
| コスト異常 | @cloud-governance | Cost Management | @cloud-governance + CFO |

---

### 4.3 インシデント対応責任

#### 4.3.1 インシデント対応フロー

```
┌────────────────────────────────────────────────────────────────────┐
│                     インシデント対応フロー                            │
│                                                                    │
│  検知（Azure Monitor / Sentinel アラート）                           │
│      │                                                             │
│      ▼                                                             │
│  トリアージ（@cloud-operations L1 – 15分以内）                        │
│      │                                                             │
│      ├── セキュリティ関連 → @cloud-security にエスカレーション          │
│      │                                                             │
│      ├── インフラ障害 → @cloud-operations L2 対応                    │
│      │       │                                                     │
│      │       └── Runbook 参照・自動復旧スクリプト実行                  │
│      │                                                             │
│      └── アプリ障害 → ワークロードチームに通知・協力対応               │
│                                                                    │
│  復旧後: PIR（Post-Incident Review）72時間以内に実施                  │
│  根本原因分析・再発防止策を Runbook・ポリシーに反映                      │
└────────────────────────────────────────────────────────────────────┘
```

#### 4.3.2 Runbook 整備計画

| Runbook 名 | 内容 | 作成期限 | 自動化水準 |
|---|---|---|---|
| VM 応答不能対応 | VM の強制再起動・スナップショット取得 | 2026年7月 | 半自動 |
| ストレージ容量超過対応 | 容量拡張・古いデータのアーカイブ | 2026年7月 | 全自動 |
| ネットワーク切断対応 | NSG・UDR の確認・修復 | 2026年8月 | 半自動 |
| SQL DB フェールオーバー | セカンダリへの手動フェールオーバー手順 | 2026年8月 | 手動ガイド |
| セキュリティ侵害初動対応 | 影響リソースの隔離・証跡保全 | 2026年9月 | 半自動 |
| コスト異常対応 | 高コストリソースの特定・一時停止 | 2026年9月 | 半自動 |

---

### 4.4 SLO/SLA 管理責任

#### 4.4.1 SLO 定義と管理

| サービス | 現在の可用性 | SLO 目標 | SLA（外部公約） | 測定方法 |
|---|---|---|---|---|
| 基幹業務システム | 99.5% | 99.95% | 99.9% | Azure Monitor Availability Test |
| 社内ポータル | 99.0% | 99.9% | 99.5% | Application Insights |
| データ分析基盤 | 98.5% | 99.5% | 99.0% | Log Analytics クエリ |
| AI/ML 推論 API | 新規 | 99.5% | 99.0% | API Management ヘルスチェック |

> **SLO 管理の原則**: SLO はワークロードチームと合意の上で設定し、@cloud-operations がその達成状況を月次でレポートします。SLO 未達が 2 ヶ月連続した場合、根本原因分析と改善計画を @cloud-governance・@cloud-strategy に報告します。

#### 4.4.2 SLO 監視 KQL クエリ

```kusto
// 可用性 SLO のトレンド（過去 30 日間）
availabilityResults
| where timestamp > ago(30d)
| summarize
    availabilityRate = round(100.0 * countif(success == true) / count(), 4),
    totalChecks = count(),
    failedChecks = countif(success == false)
    by name, bin(timestamp, 1d)
| where availabilityRate < 99.95  // SLO 未達を検出
| order by timestamp desc
```

---

### 4.5 パッチ・変更管理責任

#### 4.5.1 パッチ管理

| 対象 | パッチ方針 | 適用期限（通常） | 適用期限（重大脆弱性） | 担当 |
|---|---|---|---|---|
| Azure VM（Windows/Linux） | Azure Update Manager による自動化 | 月次（パッチ火曜日 +7日） | 48 時間以内 | @cloud-operations |
| PaaS サービス | Microsoft 管理（SLA 内） | 自動 | 自動 | Microsoft |
| 物理サーバー（120台） | 手動 + スクリプト自動化 | 月次 | 72 時間以内 | @cloud-platform + @cloud-operations |
| コンテナイメージ | CI/CD パイプラインで脆弱性スキャン | デプロイ時 | 即時（デプロイ停止） | @cloud-security + 開発チーム |

#### 4.5.2 変更管理プロセス

```
変更分類:
  ├── 標準変更（pre-approved）: 既定の Runbook に基づく変更。承認不要で即時実施
  ├── 通常変更: CAB（Change Advisory Board）で週次審議。承認後に実施
  └── 緊急変更: CISO または CTO が承認。実施後に事後報告

CAB 構成:
  ├── @cloud-operations（議長）
  ├── @cloud-security（セキュリティ影響評価）
  ├── @cloud-governance（ポリシー準拠確認）
  ├── @cloud-platform（インフラ影響評価）
  └── 関連ワークロードチーム（影響を受けるサービスが存在する場合）
```

---

## 5. AI 導入責任の計画（@cloud-platform）

### 5.1 責任領域の概要

@cloud-platform チームは、**クラウドインフラの基盤設計・Landing Zone 構築・AI/ML サービスの導入基盤整備**を担います。物理サーバー 120 台と VM 280 台の管理責任に加え、組織の AI 活用ロードマップを実現するための技術基盤構築が主要ミッションです。

---

### 5.2 AI/ML 基盤整備責任

#### 5.2.1 Azure AI サービス活用ロードマップ

```
フェーズ 0（〜2026/6）: 基盤整備
  ├── Azure OpenAI Service のデプロイ（East Japan リージョン）
  ├── AI Hub / AI Project の設計・構築
  ├── Private Endpoint によるネットワーク閉域化
  ├── Azure AI Content Safety の導入（有害コンテンツフィルタ）
  └── モデルデプロイ承認フロー（@cloud-governance と共同設計）

フェーズ 1（2026/7-12）: 社内活用の実現
  ├── 社内ナレッジ検索（RAG: Retrieval-Augmented Generation）の構築
  ├── Azure AI Search + Azure OpenAI の統合
  ├── PoC 評価・本番移行判断（@cloud-governance の AI ガバナンスレビュー）
  └── 利用状況モニタリング基盤の整備

フェーズ 2（2027/1-6）: 業務適用の拡大
  ├── Azure Machine Learning による ML 基盤（MLOps）
  ├── 予測分析・異常検知モデルの本番デプロイ
  ├── Azure Cognitive Services（Vision・Language）の業務適用
  └── AI コスト最適化（モデルサイズ・API 呼び出し最適化）

フェーズ 3（2027/7-）: AI Ops・継続改善
  ├── モデルドリフト検知・自動再トレーニング
  ├── Responsible AI の定量評価（公平性・説明可能性）
  └── AI ガバナンス成熟度の外部評価
```

#### 5.2.2 AI インフラ設計責任

| インフラコンポーネント | 担当 | 完了期限 | 備考 |
|---|---|---|---|
| Azure OpenAI リソース作成 | @cloud-platform | 2026年5月 | East Japan、GPT-4o デプロイ |
| AI Hub / AI Project 設計 | @cloud-platform | 2026年5月 | プロジェクト単位でのリソース分離 |
| Private Endpoint 設定 | @cloud-platform | 2026年6月 | パブリックアクセス無効化 |
| Azure AI Search 構築 | @cloud-platform | 2026年8月 | RAG 基盤 |
| Azure ML ワークスペース | @cloud-platform | 2026年10月 | MLOps 基盤 |
| GPU ノード（AKS） | @cloud-platform | 2026年12月 | 推論ワークロード用 |

---

### 5.3 Azure AI サービス管理責任

#### 5.3.1 Azure OpenAI Service 管理

```
クォータ管理:
  ├── トークン/分 (TPM) クォータの設定・モニタリング
  ├── デプロイメントごとのクォータ割り当て（部門別）
  └── クォータ増加申請の管理（Azure サポート経由）

コスト管理（@cloud-governance と連携）:
  ├── API 呼び出しコストの部門別チャージバック
  ├── キャッシュ戦略によるコスト最適化（Semantic Caching）
  └── 月次コストレビューでの最適化勧告

セキュリティ（@cloud-security と連携）:
  ├── API キーを廃止しマネージド ID に一元化
  ├── Azure API Management によるアクセス制御・レート制限
  └── プロンプトインジェクション対策（Content Safety）
```

#### 5.3.2 物理サーバー・VM 管理責任

| 管理対象 | 台数 | 管理方式 | 担当チーム | 移行計画 |
|---|---|---|---|---|
| 物理サーバー | 120 台 | Azure Arc による管理拡張 | @cloud-platform | FY2026: Arc 接続 → FY2027: Azure IaaS 移行または廃却 |
| Azure VM | 280 台 | IaC（Bicep/Terraform）で管理 | @cloud-platform | 継続運用（Landing Zone 配下に移行） |
| VM スケールセット | 適宜 | Azure VMSS | @cloud-platform | 自動スケーリング設定 |
| AKS クラスター | 新規 | Terraform | @cloud-platform | 2026年9月までにコンテナ基盤整備 |

---

### 5.4 AI ガバナンス責任

#### 5.4.1 AI ガバナンスフレームワーク

@cloud-platform が AI 基盤を構築する一方、AI の利用・管理に関するガバナンスは **@cloud-governance と共同で設計・適用**します。

| ガバナンス領域 | 主責任 | 支援 | 具体的な統制 |
|---|---|---|---|
| AI モデル利用承認 | @cloud-governance | @cloud-platform | モデルデプロイ前のリスクアセスメント必須化 |
| AI コスト管理 | @cloud-governance | @cloud-platform | Azure OpenAI コストをタグで追跡・部門別配賦 |
| AI セキュリティ | @cloud-security | @cloud-platform | Content Safety・プロンプト監査ログ |
| AI 利用ポリシー | @cloud-governance | CCoE | AI 利用ガイドライン策定・全組織員への周知 |
| Responsible AI | @cloud-platform | @cloud-governance | 公平性・説明可能性・透明性の評価 |

#### 5.4.2 AI ガバナンス Azure Policy

```bicep
// AI サービスのパブリックアクセス禁止（Deny ポリシー）
resource denyOpenAIPublicAccess 'Microsoft.Authorization/policyAssignments@2024-04-01' = {
  name: 'deny-openai-public-access'
  properties: {
    displayName: 'Azure OpenAI パブリックネットワークアクセスの禁止'
    description: 'AI ガバナンス: OpenAI リソースはプライベートエンドポイント経由のみアクセス許可'
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/438c38d2-3bf0-4b41-b8ca-bf7c2f2e4c79'
    enforcementMode: 'Default'
  }
}
```

---

### 5.5 データ品質・倫理責任

#### 5.5.1 AI データ管理責任

| 責任項目 | 担当 | 内容 | 期限 |
|---|---|---|---|
| データ分類 | @cloud-governance + @cloud-platform | Microsoft Purview による個人情報・機密情報の自動分類 | 2026年8月 |
| 学習データ品質 | @cloud-platform | データリネージ管理・品質メトリクスの定義 | 2026年10月 |
| 個人情報の AI 学習利用禁止 | @cloud-governance | ポリシー策定・技術的フィルタリング | 2026年6月 |
| AI 出力の監査ログ | @cloud-security | OpenAI 診断ログの Log Analytics 転送 | 2026年6月 |

#### 5.5.2 Responsible AI チェックリスト（本番デプロイ前必須）

```
□ 公平性評価: 性別・年齢・人種等の属性でバイアスがないことを確認
□ 信頼性・安全性: 障害モードの特定・フォールバック動作の実装
□ プライバシー: 個人情報が学習データに含まれないことを確認
□ 包括性: 障害者・マイノリティへの影響評価
□ 透明性: AI を使用していることをエンドユーザーに開示
□ 説明可能性: 主要な判断に対する説明機能の実装（高リスク用途のみ）
□ @cloud-governance による最終承認
```

---

## 6. 統合 RACI マトリックス

### 6.1 RACI の定義

| 記号 | 意味 |
|---|---|
| **R** | Responsible（実行責任）: 実際に作業を実施する |
| **A** | Accountable（説明責任）: 成果に対して最終責任を持つ。各項目に必ず 1 名 |
| **C** | Consulted（相談先）: 意思決定前に意見を求める |
| **I** | Informed（報告先）: 決定・実施後に通知を受ける |

### 6.2 ガバナンス・コンプライアンス領域

| 活動 | @cloud-governance | @cloud-security | @cloud-operations | @cloud-platform | CCoE | 外部パートナー |
|---|---|---|---|---|---|---|
| Azure Policy 設計 | **R/A** | C | C | C | C | I |
| Azure Policy 実装（IaC） | R | I | I | **R/A** | C | I |
| ポリシー例外承認 | **A** | C | I | I | C | ー |
| コンプライアンス監視 | **R/A** | C | C | I | I | ー |
| リスクアセスメント | **R/A** | C | C | C | C | ー |
| 予算・コスト管理 | **R/A** | I | C | C | I | ー |
| タグ戦略策定 | **R/A** | I | C | C | C | ー |
| 規制対応（ISMAP等） | **R/A** | C | C | I | C | C（監査法人）|
| ガバナンス成熟度評価 | R | C | C | C | **A** | ー |

### 6.3 セキュリティ領域

| 活動 | @cloud-governance | @cloud-security | @cloud-operations | @cloud-platform | CCoE | 外部パートナー |
|---|---|---|---|---|---|---|
| セキュリティベースライン定義 | C | **R/A** | C | C | C | ー |
| ゼロトラスト設計 | C | **R/A** | C | C | I | ー |
| Defender for Cloud 構成 | C | **R/A** | C | R | I | ー |
| Microsoft Sentinel 構築 | I | **R/A** | C | C | I | ー |
| セキュリティインシデント対応 | I | **R/A** | C | C | I | C（MSSP）|
| 脆弱性管理 | C | **R/A** | R | R | I | ー |
| ペネトレーションテスト | C | **A** | I | I | I | **R**（委託）|
| セキュリティ教育 | I | **R/A** | I | I | C | ー |
| アクセスレビュー（四半期） | C | **R/A** | I | I | C | ー |

### 6.4 運用・監視領域

| 活動 | @cloud-governance | @cloud-security | @cloud-operations | @cloud-platform | CCoE | 外部パートナー |
|---|---|---|---|---|---|---|
| Log Analytics Workspace 設計 | I | C | **R/A** | C | I | ー |
| Azure Monitor 構成 | I | C | **R/A** | C | I | ー |
| アラートルール設定 | I | C | **R/A** | C | I | ー |
| インシデント対応（インフラ） | I | C | **R/A** | C | I | ー |
| SLO 定義・管理 | C | I | **R/A** | C | C | ー |
| 変更管理（CAB 運営） | C | C | **R/A** | C | I | ー |
| パッチ管理（VM） | I | C | **R/A** | R | I | ー |
| バックアップ管理 | C | I | **R/A** | R | I | ー |
| Runbook 整備 | I | C | **R/A** | C | I | ー |
| 可用性レポート | C | I | **R/A** | I | I | ー |

### 6.5 プラットフォーム・AI 領域

| 活動 | @cloud-governance | @cloud-security | @cloud-operations | @cloud-platform | CCoE | 外部パートナー |
|---|---|---|---|---|---|---|
| Landing Zone 設計 | C | C | C | **R/A** | C | ー |
| Landing Zone 実装（IaC） | C | C | I | **R/A** | I | ー |
| 管理グループ階層設計 | **R** | C | I | **A** | C | ー |
| ネットワーク設計（Hub-Spoke） | C | C | C | **R/A** | C | ー |
| Azure OpenAI 基盤構築 | C | C | I | **R/A** | I | ー |
| AI ガバナンスポリシー策定 | **R/A** | C | I | C | C | ー |
| AI コスト管理 | **R/A** | I | I | C | I | ー |
| Responsible AI 評価 | C | I | I | **R/A** | C | ー |
| 物理サーバー管理 | I | I | C | **R/A** | I | C（SIer）|
| VM 管理（IaC） | C | I | C | **R/A** | I | ー |

### 6.6 外部パートナーの位置付け

| 外部パートナー | 役割 | 関与する活動 | 関与形態 |
|---|---|---|---|
| **Microsoft（Azure サポート）** | プラットフォームサポート | クォータ増加・障害対応・技術相談 | Consulted |
| **監査法人** | コンプライアンス監査 | ISMAP・ISO 27001・PCI DSS 審査 | Responsible（審査）|
| **MSSP（セキュリティ委託先）** | SOC 運用支援 | 24/7 セキュリティ監視・インシデント初動 | Responsible（実行）|
| **SIer（インフラ委託先）** | 物理インフラ保守 | 物理サーバー保守・DC 運用 | Responsible（実行）|
| **コンサルティング会社** | 変革支援 | CAF 導入支援・組織変革マネジメント | Consulted |

---

## 7. 責任境界の定義

### 7.1 クラウド共有責任モデル

Azure の共有責任モデルに基づき、Microsoft と組織の責任を明確化します。

```
┌─────────────────────────────────────────────────────────────────────┐
│                    責任境界マップ                                      │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │               組織の責任（Our Responsibility）                │   │
│  │                                                             │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │   │
│  │  │   データ・情報  │  │  アプリケーション│  │  ID・アクセス管理  │  │   │
│  │  │ @cloud-gov   │  │  ワークロード  │  │  @cloud-security│  │   │
│  │  │ @cloud-sec   │  │  チーム      │  │  @cloud-gov     │  │   │
│  │  └──────────────┘  └──────────────┘  └──────────────────┘  │   │
│  │                                                             │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │   │
│  │  │ OS・ランタイム │  │ ネットワーク   │  │  ファイアウォール   │  │   │
│  │  │ @cloud-ops   │  │ 設定・制御    │  │  設定            │  │   │
│  │  │ @cloud-plat  │  │ @cloud-plat  │  │  @cloud-sec     │  │   │
│  │  └──────────────┘  └──────────────┘  └──────────────────┘  │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │               Microsoft の責任                                │   │
│  │  物理ホスト / 物理ネットワーク / 物理データセンター              │   │
│  │  → SLA の範囲内で Microsoft が保証                            │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

### 7.2 サービスモデル別の責任分担

| 責任領域 | IaaS | PaaS | SaaS |
|---|---|---|---|
| データ・情報 | 組織 | 組織 | 組織 |
| デバイス・アカウント | 組織 | 組織 | 組織 |
| ID・アクセス管理 | 組織 | 組織 | 組織 |
| アプリケーション | 組織 | 組織 | **Microsoft** |
| ネットワーク制御 | 組織 | **共有** | **Microsoft** |
| OS | 組織 | **Microsoft** | **Microsoft** |
| 物理ホスト | **Microsoft** | **Microsoft** | **Microsoft** |

### 7.3 各チームの責任境界詳細

#### @cloud-governance の責任境界

```
責任範囲（IN）:
  ✅ Azure Policy の定義・割り当て・管理
  ✅ 管理グループ階層の設計（@cloud-platform と共同）
  ✅ コンプライアンス状況の監視とレポート
  ✅ FinOps プロセスの主導（コスト配賦・最適化）
  ✅ リスクレジスターの管理・リスクアセスメント
  ✅ AI ガバナンスポリシーの策定

責任範囲外（OUT）:
  ❌ Azure Policy の IaC 実装（→ @cloud-platform が実施）
  ❌ セキュリティインシデントの技術対応（→ @cloud-security）
  ❌ インフラの設計・構築（→ @cloud-platform）
  ❌ 監視基盤の実装（→ @cloud-operations）
```

#### @cloud-security の責任境界

```
責任範囲（IN）:
  ✅ セキュリティアーキテクチャの設計（ゼロトラスト含む）
  ✅ Microsoft Defender for Cloud / Sentinel の設計・運用
  ✅ セキュリティインシデントの検知・対応・封じ込め
  ✅ 脆弱性管理プロセスの策定・推進
  ✅ セキュリティ教育・意識向上プログラムの実施
  ✅ ISMAP・ISO 27001 の技術統制証跡の管理

責任範囲外（OUT）:
  ❌ ポリシーの設計・割り当て（→ @cloud-governance）
  ❌ ネットワークインフラの実装（→ @cloud-platform）
  ❌ 日常的な運用監視（→ @cloud-operations）
  ❌ コスト管理・予算設定（→ @cloud-governance）
```

#### @cloud-operations の責任境界

```
責任範囲（IN）:
  ✅ Azure Monitor・Log Analytics の構築・運用
  ✅ インフラ・OS レベルのインシデント対応
  ✅ SLO の定義・測定・レポート
  ✅ 変更管理プロセス（CAB）の運営
  ✅ パッチ管理（VM・OS 層）
  ✅ Runbook の整備・維持

責任範囲外（OUT）:
  ❌ セキュリティインシデントの対応主体（→ @cloud-security）
  ❌ アプリケーション層の障害対応（→ ワークロードチーム）
  ❌ インフラ設計・IaC 実装（→ @cloud-platform）
  ❌ ポリシー設計（→ @cloud-governance）
```

#### @cloud-platform の責任境界

```
責任範囲（IN）:
  ✅ Landing Zone の設計・IaC 実装（Bicep/Terraform）
  ✅ 管理グループ・サブスクリプション階層の実装
  ✅ ネットワーク基盤（Hub-Spoke、Firewall、VPN/ExpressRoute）
  ✅ 物理サーバー（120台）と VM（280台）の管理
  ✅ Azure AI 基盤（OpenAI、AI Hub、ML Workspace）の構築
  ✅ Azure Policy の IaC 実装（ポリシー定義は @cloud-governance）

責任範囲外（OUT）:
  ❌ ポリシー設計・コンプライアンス監視（→ @cloud-governance）
  ❌ セキュリティインシデント対応（→ @cloud-security）
  ❌ 日常的な監視・運用（→ @cloud-operations）
  ❌ アプリケーションのデプロイ・管理（→ ワークロードチーム）
```

---

## 8. フェーズ別責任の変化

### 8.1 フェーズ概要

クラウド導入は以下の 3 フェーズで進行します。各フェーズで各チームの責任の重点が変化します。

| フェーズ | 期間 | テーマ | KPI |
|---|---|---|---|
| **フェーズ 1: 基盤確立** | 2026年4月〜2026年9月 | ガバナンス基盤・セキュリティ基盤・監視基盤の整備 | ガバナンス Level 3 達成・Defender 全展開 |
| **フェーズ 2: 本格移行** | 2026年10月〜2027年3月 | ワークロード移行・SLO 達成・ゼロトラスト実装 | 可用性 99.95%・対応時間 4 時間 |
| **フェーズ 3: 最適化** | 2027年4月〜2027年9月 | AI 活用・自動化・FinOps 成熟 | ガバナンス Level 4・AI ワークロード 3 以上 |

---

### 8.2 フェーズ 1: 基盤確立フェーズ（2026年4月〜9月）

#### 各チームの重点責任

| チーム | フェーズ 1 の重点責任 | 成果物 |
|---|---|---|
| **@cloud-governance** | Azure Policy の Audit モード適用・タグ戦略整備・FinOps プロセス確立 | ポリシーイニシアティブ定義・コストダッシュボード |
| **@cloud-security** | Defender for Cloud 全展開・Sentinel 基本構成・MFA 全適用 | セキュリティスコアベースライン・インシデント対応フロー |
| **@cloud-operations** | Log Analytics 構築・基本アラート設定・Runbook 初期整備 | 監視基盤・Runbook 5 本 |
| **@cloud-platform** | Landing Zone 構築・管理グループ設計・Azure Arc 導入（物理サーバー） | Landing Zone IaC・ネットワーク基盤 |

#### フェーズ 1 マイルストーン

```
2026年5月末: Landing Zone MVP 完成（@cloud-platform）
2026年6月末: 個人情報保護法改正対応完了（@cloud-governance + @cloud-security）
2026年6月末: Defender for Cloud 全展開（@cloud-security）
2026年7月末: Log Analytics Workspace 構築・アラート設定完了（@cloud-operations）
2026年9月末: Azure Arc による物理サーバー管理開始（@cloud-platform）
2026年9月末: ガバナンス成熟度 Level 3 達成（@cloud-governance）
```

---

### 8.3 フェーズ 2: 本格移行フェーズ（2026年10月〜2027年3月）

#### 各チームの重点責任

| チーム | フェーズ 2 の重点責任 | 成果物 |
|---|---|---|
| **@cloud-governance** | コスト管理ポリシーの Deny 移行・コンプライアンス自動化・ISO 27001 拡大対応 | Deny ポリシー・KPI ダッシュボード |
| **@cloud-security** | ゼロトラスト Phase 1（ID・デバイス）・Sentinel SOAR 実装・PCI DSS 対応 | インシデント対応時間 4 時間達成 |
| **@cloud-operations** | SLO 99.95% 達成・変更管理 CAB 確立・パッチ自動化 | SLO 達成レポート・変更記録 |
| **@cloud-platform** | 主要ワークロード移行支援・Azure OpenAI 基盤・MLOps 基盤整備 | AI 基盤・移行完了 IaC |

#### フェーズ 2 マイルストーン

```
2026年11月末: ISMAP 年次更新対応完了（@cloud-governance + @cloud-security）
2026年12月末: ISO 27001 拡大認証取得（@cloud-governance 主導）
2027年1月末: ゼロトラスト Phase 1 完了（@cloud-security）
2027年2月末: Sentinel SOAR による自動対応実装（@cloud-security）
2027年3月末: インシデント対応時間 4 時間達成（@cloud-security + @cloud-operations）
2027年3月末: 可用性 SLO 99.95% 達成（@cloud-operations）
```

---

### 8.4 フェーズ 3: 最適化フェーズ（2027年4月〜9月）

#### 各チームの重点責任

| チーム | フェーズ 3 の重点責任 | 成果物 |
|---|---|---|
| **@cloud-governance** | ガバナンス Level 4 達成・AI ガバナンス成熟・FinOps Run フェーズ | 自動コンプライアンスレポート・FinOps 最適化 |
| **@cloud-security** | ゼロトラスト Phase 2（ネットワーク・データ）・Insider Risk 対応 | ゼロトラスト全体完成 |
| **@cloud-operations** | AI Ops 導入（異常検知自動化）・SLO 継続改善・コスト最適化 | 運用成熟度 4.0 達成 |
| **@cloud-platform** | AI ワークロード 3 以上の本番稼働・MLOps 自動化・物理サーバー廃却計画 | AI ロードマップ達成 |

#### フェーズ 3 マイルストーン

```
2027年6月末: ガバナンス成熟度 Level 4 達成（@cloud-governance）
2027年6月末: AI ワークロード 3 本以上の本番稼働（@cloud-platform）
2027年7月末: ゼロトラスト Phase 2 完了（@cloud-security）
2027年9月末: FinOps Run フェーズ到達（@cloud-governance）
2027年9月末: 運用成熟度 4.0 達成（@cloud-operations）
2027年9月末: 物理サーバー廃却計画の策定・承認（@cloud-platform）
```

---

### 8.5 フェーズ別 KPI サマリー

| KPI | フェーズ 1 末 | フェーズ 2 末 | フェーズ 3 末 |
|---|---|---|---|
| ガバナンス成熟度 | Level 3（定義） | Level 3〜4 | **Level 4（測定）** |
| セキュリティスコア（Defender） | 60 以上 | 75 以上 | **85 以上** |
| インシデント対応時間（重大） | 24 時間以内 | 4 時間以内 | **4 時間以内（維持）** |
| 可用性 | 99.5% → 99.7% | 99.9% → 99.95% | **99.95%（維持）** |
| Azure Policy 適用率（Deny） | 0%（全 Audit） | 50%（コスト・セキュリティ） | **100%** |
| AI ワークロード数 | 0 | 1〜2（PoC） | **3 以上（本番）** |
| FinOps 成熟度 | Crawl | Walk | **Run** |
| タグ付与率（必須タグ） | 100%（強制） | 100%（維持） | **100%（維持）** |

---

## 付録 A: 用語集

| 用語 | 説明 |
|---|---|
| **RACI** | Responsible（実行）/ Accountable（説明責任）/ Consulted（相談）/ Informed（報告）の責任分担フレームワーク |
| **CSPM** | Cloud Security Posture Management。クラウド環境のセキュリティ構成の継続的な評価・改善 |
| **SOAR** | Security Orchestration Automated Response。セキュリティインシデント対応の自動化 |
| **SIEM** | Security Information and Event Management。セキュリティイベントの収集・分析・対応 |
| **FinOps** | クラウド財務管理のフレームワーク。コストの可視化・最適化・説明責任を文化として定着させる |
| **SLO** | Service Level Objective。内部的な目標サービスレベル |
| **SLA** | Service Level Agreement。外部公約としてのサービスレベル合意 |
| **CAB** | Change Advisory Board。変更管理の審議機関 |
| **PIM** | Privileged Identity Management。Just-In-Time の特権アクセス管理 |
| **MLOps** | Machine Learning Operations。ML モデルの開発・デプロイ・運用の自動化 |
| **RAG** | Retrieval-Augmented Generation。外部知識を検索して LLM の回答を補強する手法 |
| **ISMAP** | 政府情報システムのためのセキュリティ評価制度（Information system Security Management and Assessment Program）|

---

## 付録 B: 関連文書一覧

| 文書名 | パス | 関連チーム |
|---|---|---|
| クラウド導入戦略評価レポート | `outputs/01_strategy/strategy_assessment.md` | 全チーム |
| クラウド導入体験マッピング | `outputs/02_plan/cloud_adoption_experience.md` | 全チーム |
| クラウド運用モデル定義書 | `outputs/02_plan/operating_model.md` | 全チーム |
| Azure Policy ガイドライン | `.github/instructions/policy.instructions.md` | @cloud-governance |
| Bicep 実装ガイドライン | `.github/instructions/bicep.instructions.md` | @cloud-platform |
| Terraform 実装ガイドライン | `.github/instructions/terraform.instructions.md` | @cloud-platform |

---

*本文書は Azure CAF 計画フェーズの成果物として、CCoE の承認を経て確定します。次回レビュー予定: 2026年7月（フェーズ 1 マイルストーン評価時）*

---

## @devils-advocate レビュー記録

**レビュー実施日**: 2026年4月12日  
**レビュアー**: @devils-advocate  
**レビュー対象バージョン**: 1.0  

### 指摘事項一覧

| # | 深刻度 | 指摘タイトル | 改善提案の概要 | 解消状況 |
|---|---|---|---|---|
| 1 | 🔴 Critical | AI 導入責任が技術的準備度 1.5/5.0 の組織に対して過大（ゲート条件なし） | Gate 1/Gate 2 の前提条件（Landing Zone 完成・Defender 展開）を定義し AI 導入を条件付きにする | ⏳ `adoption_plan.md` で Gate 定義を追加予定 |
| 2 | 🔴 Critical | PCI DSS v4.0 の維持管理責任（年次レビュー）が RACI から漏れている | @cloud-governance の継続タスクとして追記し ISMAP 対応と同時期のスケジュールを明記する | ⏳ `adoption_plan.md` に持ち越し |
| 3 | 🟠 High | MSSP との責任境界が未定義 ― P1 インシデント時の「責任の谷間」 | MSSP インシデント対応の RACI を補足し、内部 SLA との整合要件を明記する | ⏳ 外部パートナー選定時に ROB として対処予定 |
| 4 | 🟠 High | CCoE の構成・権限が未定義のまま Accountable に設定されている | operating_model.md の CCoE 定義への参照を追加し、発足前の暫定対応を明記する | ⏳ `adoption_plan.md` で CCoE 発足手順を記載予定 |
| 5 | 🟠 High | フェーズ 1 で @cloud-operations に要求される能力が現状成熟度（2.5/5.0）を超えている | フェーズ 1 でのスコープをアラート設定・基本 Runbook 整備に限定し外部パートナー支援を明記する | ⏳ 部分解消（adoption_plan.md でトレーニング計画と紐付け） |
| 6 | 🟠 High | 責任が SLO 未達のときの対応が未定義（SLO ≠ 責任トリガー） | SLO 未達時のエスカレーションと責任者変更の基準を追記する | ⏳ `adoption_plan.md` に持ち越し |
| 7 | 🟡 Medium | ガバナンス・セキュリティの Deny ポリシー適用時の既存ワークロードへの影響評価が未記載 | 既存ワークロードへの影響評価プロセスを §2 に追記する | ⏳ 次成果物に持ち越し |
| 8 | 🟡 Medium | 変更管理 CAB の定足数・意思決定方式が未定義 | CAB 定足数・議決方式・緊急変更ファストトラックを §4 に追記する | ⏳ `adoption_plan.md` に持ち越し |

### 重大指摘の解消状況チェックリスト

- [ ] Critical-1: AI 導入の Gate 1/Gate 2 前提条件が `adoption_plan.md` に定義された
- [ ] Critical-2: PCI DSS v4.0 年次維持責任が RACI に追記された
- [ ] High-1: MSSP との P1 インシデント対応 RACI 補足が契約要件として文書化された
- [ ] High-2: CCoE Accountable の発足前暫定対応が明記された
- [ ] High-3: フェーズ 1 の @cloud-operations スコープが現成熟度に合わせて調整された
- [ ] High-4: SLO 未達時のエスカレーション基準が `adoption_plan.md` に記載された

### `adoption_plan.md` への持ち越し事項

1. AI 導入の Gate 1/Gate 2 前提条件の詳細定義（Critical-1）
2. PCI DSS v4.0 年次維持責任の RACI への追記（Critical-2）
3. フェーズ移行時の SLO エスカレーション基準（High-4）
4. Change Management プログラムとトレーニング計画（High-3 に関連）
5. CCoE 発足手順・暫定対応期間の定義（High-2）
