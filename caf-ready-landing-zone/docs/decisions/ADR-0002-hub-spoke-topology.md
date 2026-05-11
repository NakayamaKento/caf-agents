# ADR-0002: Hub-Spoke ネットワークトポロジの採用

- **ステータス**: Accepted
- **日付**: 2026-05-11
- **決定者**: Platform Team (@NakayamaKento)

## コンテキスト

Landing Zone のネットワークトポロジとして、以下の候補を検討した:

1. **Hub-Spoke** — 集約 Hub VNet + Spoke VNet のピアリング
2. **Virtual WAN (vWAN)** — Microsoft マネージドのグローバルネットワーク
3. **フラット（シングル VNet）** — 単一 VNet に全ワークロード

初期フェーズは国内（Japan East + Japan West）のみの展開で、グローバル展開は将来検討事項。

## 決定事項

**Hub-Spoke トポロジ**（`avm/ptn/network/hub-networking` 利用）を採用する。

## 理由

| 観点 | Hub-Spoke | vWAN | フラット |
|---|---|---|---|
| グローバル展開 | △ 手動管理 | ◎ 自動 | × 不向き |
| コスト | ○ 中程度 | △ 高め | ○ 低 |
| セキュリティ（FW 集約） | ◎ Hub に集約 | ◎ vWAN に集約 | × 困難 |
| 移行容易性 | ○ vWAN への移行可 | — | × |
| AVM 対応 | ◎ `avm/ptn/network/hub-networking` | ◎ `avm/ptn/network/virtual-wan` | — |

初期フェーズでのコスト最適化と、将来的な vWAN への移行容易性を考慮して Hub-Spoke を選択した。

## 結果

- ✅ 国内 2 リージョンの展開に適したシンプルな構成
- ✅ Azure Firewall を Hub に集約してセキュリティを確保
- ✅ Spoke VNet を追加するだけでワークロードを拡張可能
- ⚠️ グローバル展開（5 リージョン以上）時は vWAN への移行を検討

## 代替案

- **Virtual WAN**: グローバル展開が 3 リージョン以上になった場合に ADR-0002-rev2 として再評価する
