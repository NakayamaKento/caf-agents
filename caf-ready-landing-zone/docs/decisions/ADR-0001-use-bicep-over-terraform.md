# ADR-0001: IaC ツールとして Azure Bicep を採用

- **ステータス**: Accepted
- **日付**: 2026-05-11
- **決定者**: Platform Team (@NakayamaKento)

## コンテキスト

Azure Landing Zone の IaC ツールとして、以下の候補を検討した:

1. **Azure Bicep** — Azure ネイティブの DSL
2. **Terraform (AzureRM)** — クロスクラウド対応の OSS ツール
3. **ARM テンプレート** — Bicep の元となる JSON 形式

チームはすでに Azure を主要クラウドとして採用しており、他クラウドへの移行予定はない。

## 決定事項

**Azure Bicep** を IaC ツールとして採用する。

## 理由

| 観点 | Bicep | Terraform |
|---|---|---|
| Azure 最新 API の追従 | ◎ ネイティブ対応 | △ プロバイダー更新待ち |
| 記述量 | ○ 簡潔 | ○ 簡潔 |
| Azure Verified Modules | ◎ AVM 公式対応 | △ 一部のみ対応 |
| State 管理 | 不要（Azure が管理） | ○ Backend 設定が必要 |
| マルチクラウド | × 非対応 | ◎ 対応 |
| 学習コスト | ○ 低（Azure 知識で十分） | △ 中（HCL 習得が必要） |

チームの Azure 集中戦略と AVM 活用方針を踏まえ、Bicep が最適と判断した。

## 結果

- ✅ Azure の最新機能を即座に利用できる
- ✅ AVM Pattern Modules との親和性が高い
- ✅ State ファイル管理が不要でオペレーション負荷が低い
- ⚠️ マルチクラウド展開が必要になった場合は再評価が必要

## 代替案

- **Terraform**: マルチクラウド要件が発生した場合に再評価する
- **ARM テンプレート**: Bicep にトランスパイルして使用するため不要
