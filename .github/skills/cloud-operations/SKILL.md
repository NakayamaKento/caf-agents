# Cloud Operations スキル

このスキルファイルは `@cloud-operations` エージェントが提供する再利用可能な知識・手順を定義します。

---

## スキル 1: Azure Monitor アーキテクチャ

```
┌─────────────────────────────────────────────────┐
│                  Azure Monitor                   │
│                                                  │
│  ┌──────────┐  ┌──────────┐  ┌───────────────┐  │
│  │ Metrics   │  │ Logs     │  │ Traces        │  │
│  │ Platform  │  │ Activity │  │ App Insights  │  │
│  │ Guest     │  │ Resource │  │ Distributed   │  │
│  │ Custom    │  │ Entra ID │  │ Tracing       │  │
│  └────┬─────┘  └────┬─────┘  └──────┬────────┘  │
│       │              │               │           │
│  ┌────▼──────────────▼───────────────▼────────┐  │
│  │         Log Analytics Workspace             │  │
│  └────┬──────────────┬───────────────┬────────┘  │
│       │              │               │           │
│  ┌────▼────┐  ┌──────▼─────┐  ┌─────▼───────┐  │
│  │ Alerts  │  │ Dashboards │  │ Workbooks   │  │
│  │ Actions │  │ Grafana    │  │ Reports     │  │
│  └─────────┘  └────────────┘  └─────────────┘  │
└─────────────────────────────────────────────────┘
```

### Log Analytics Workspace 設計パターン

| パターン | ユースケース | 推奨シナリオ |
|---|---|---|
| **集中型** | 小〜中規模組織 | 運用の簡素化を優先 |
| **分散型** | データ主権・アクセス制御が厳格 | 規制でデータ分離が必要 |
| **ハイブリッド型** | 大規模組織 | 集中監視と自律性を両立 |

---

## スキル 2: SLI / SLO / SLA / エラーバジェット

### 概念整理

| 概念 | 定義 | 例 |
|---|---|---|
| **SLI** (Service Level Indicator) | 実際のサービス品質を計測する指標 | 可用性 99.95%、P99 レイテンシ 200ms |
| **SLO** (Service Level Objective) | SLI の目標値（内部目標） | 可用性 99.9% / 月 |
| **SLA** (Service Level Agreement) | ユーザーとの契約上の保証 | 可用性 99.5% / 月 |
| **エラーバジェット** | SLO と 100% の差 | 月間 43.8 分のダウンタイム許容 |

### エラーバジェット計算

```
エラーバジェット = (1 - SLO) × 期間
例: SLO 99.9% / 月 → (1 - 0.999) × 43,200分 = 43.2分
```

---

## スキル 3: アラート設計の重大度レベル

| Severity | 名称 | 対応時間 | 例 |
|---|---|---|---|
| **Sev 0** | クリティカル | 即時（15 分以内） | 全サービス停止、データ損失リスク |
| **Sev 1** | 高 | 30 分以内 | 主要機能の部分的停止 |
| **Sev 2** | 中 | 4 時間以内 | パフォーマンス劣化、非主要機能の停止 |
| **Sev 3** | 低 | 次の営業日 | 警告、リソース閾値への接近 |

---

## スキル 4: KQL クエリテンプレート集

### 可用性監視

```kusto
// サービスの可用性率を計算（過去 30 日間）
let timeRange = 30d;
let totalRequests = requests
| where timestamp > ago(timeRange)
| count;
let failedRequests = requests
| where timestamp > ago(timeRange)
| where success == false
| count;
print availability = (1.0 - todouble(toscalar(failedRequests)) / todouble(toscalar(totalRequests))) * 100
```

### エラー率のトレンド分析

```kusto
requests
| where timestamp > ago(7d)
| summarize
    total = count(),
    failed = countif(success == false)
    by bin(timestamp, 1h)
| extend errorRate = todouble(failed) / todouble(total) * 100
| render timechart
```

### リソース使用率の上位 10

```kusto
Perf
| where TimeGenerated > ago(1h)
| where CounterName == "% Processor Time"
| summarize avgCPU = avg(CounterValue) by Computer
| top 10 by avgCPU desc
```

### インシデント対応タイムライン

```kusto
AzureActivity
| where TimeGenerated > ago(24h)
| where Level in ("Critical", "Error")
| project TimeGenerated, ResourceGroup, ResourceId, OperationNameValue, ActivityStatusValue
| order by TimeGenerated desc
```

---

## スキル 5: インシデント対応プロセス

```
[検知] アラート発報 (Azure Monitor / Sentinel)
    │
    ▼
[初期対応 (Sev 0-1: 15分以内)]
    │ インシデントチケット作成
    │ 関係者への初期通知
    │
    ▼
[影響評価]
    │ ビジネスインパクトの判断
    │ エスカレーション判断
    │
    ▼
[対応・復旧]
    │ ランブック / プレイブックの実行
    │ 自動復旧（可能な場合）
    │ 手動対応
    │
    ▼
[復旧確認]
    │ SLO 回復の確認
    │ ステークホルダーへの報告
    │
    ▼
[ポストモーテム (48時間以内)]
    │ 根本原因分析 (RCA)
    │ 再発防止策の策定
    └── 知識ベースへの登録
```

---

## スキル 6: Application Insights インストルメンテーション

### 計装レベル別設定

| レベル | 内容 | 推奨用途 |
|---|---|---|
| **基本** | リクエスト・例外・依存関係の自動収集 | すべてのアプリ |
| **標準** | カスタムイベント・メトリクスの追加 | 重要なビジネスイベント追跡 |
| **詳細** | 分散トレース・詳細プロファイリング | パフォーマンス問題の診断 |

---

*参照エージェント: `@cloud-operations`*
*関連スキル: `.github/skills/cloud-platform/SKILL.md`, `.github/skills/cloud-security/SKILL.md`*
