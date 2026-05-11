# ADR-0003: Azure Verified Modules (AVM) Pattern Modules の活用

- **ステータス**: Accepted
- **日付**: 2026-05-11
- **決定者**: Platform Team (@NakayamaKento)

## コンテキスト

Landing Zone の構築に使用する Bicep モジュールのソースとして、以下を検討した:

1. **Azure Verified Modules (AVM)** — Microsoft が品質保証するモジュール集
2. **自前モジュール** — 完全内製
3. **ALZ Bicep** — Azure Landing Zones 専用の Bicep モジュール集

## 決定事項

**AVM Pattern Modules** を優先的に活用し、AVM で提供されない機能のみ自前モジュールを作成する。

具体的には以下の AVM を採用:
- `avm/ptn/lz/sub-vending` — サブスクリプション自動発行
- `avm/ptn/network/hub-networking` — Hub-Spoke ネットワーク構築

## 理由

| 観点 | AVM | 自前 | ALZ Bicep |
|---|---|---|---|
| 品質保証 | ◎ Microsoft が管理 | △ 自己管理 | ○ コミュニティ |
| メンテナンス負荷 | ○ 低 | × 高 | ○ 低 |
| カスタマイズ性 | ○ パラメータで制御 | ◎ 完全自由 | △ 限定的 |
| 更新頻度 | ◎ 高 | — | ○ 中 |
| ドキュメント | ◎ 充実 | × なし | ○ あり |

## 結果

- ✅ Microsoft サポート範囲内でのベストプラクティスを自動的に取り込める
- ✅ バグフィックスや新機能を AVM バージョンアップで取得できる
- ✅ セキュリティデフォルト（HTTPS 強制、暗号化等）が組み込み済み
- ⚠️ AVM のバージョンアップ時に breaking changes が発生する可能性がある（ピン留め管理が必要）

## 代替案

- **ALZ Bicep**: AVM が十分に成熟していない機能が多い場合に再評価する
