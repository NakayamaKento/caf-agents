---
name: agent-review
description: CAF エージェントの品質評価を実施するための標準プロンプトテンプレート
---

# エージェント品質評価プロンプト

このプロンプトファイルは `.github/agents/` 配下のエージェントを体系的に評価するために使用します。

---

## 使い方

このプロンプトファイルを使用するには、以下のいずれかの方法を選択してください:

1. **単体評価**: `@copilot-expert` に評価を依頼
2. **CAF 準拠評価**: `@hr-evaluation` に評価を依頼
3. **全エージェント評価**: 以下のプロンプトをそのまま使用

---

## プロンプト 1: 単体エージェント評価（copilot-expert フレームワーク）

```
@copilot-expert 以下の評価を実施してください。

**評価対象**: .github/agents/{agent-name}.agent.md

評価観点（各 5 点、35 点満点）:
1. フォーマット準拠度
2. description の品質
3. ツールの最小権限
4. バウンダリ定義
5. 具体例の有無
6. Agent Skills 連携 (.github/skills/ の活用)
7. Custom Instructions 活用 (.github/copilot-instructions.md との整合)

評価後、スコアが 28/35 未満の場合は以下の改善提案を作成してください:
- 各観点の Before/After 改善例
- 優先度付き改善アクションリスト
```

---

## プロンプト 2: 全エージェント一括評価

```
@copilot-expert .github/agents/ 配下のすべての CAF エージェントを評価してください。

評価対象:
- cloud-strategy.agent.md
- cloud-governance.agent.md
- cloud-platform.agent.md
- cloud-operations.agent.md
- cloud-security.agent.md
- ccoe.agent.md

以下のフォーマットで出力してください:
1. 各エージェントの 35 点満点スコア表
2. スコアが 28/35 未満のエージェントへの改善提案
3. 全エージェント共通の改善事項

また、以下のファイルの有無も確認してください:
- .github/copilot-instructions.md
- .github/skills/{agent-name}/SKILL.md
- .github/instructions/*.instructions.md
- .github/prompts/agent-review.prompt.md
```

---

## プロンプト 3: CAF 準拠度評価（hr-evaluation フレームワーク）

```
@hr-evaluation .github/agents/ 配下の全エージェントを一括評価してください。

評価観点（各 5 点、25 点満点）:
1. CAF 準拠度（Azure CAF 公式ガイダンスへの準拠）
2. 役割の明確さ（責任分界、他エージェントとの境界）
3. 実用性（コード例、KQL クエリ、具体的手順）
4. 他エージェントとの連携（RACI、双方向の連携定義）
5. セキュリティ考慮（最小権限、暗号化、監査ログ）

以下を含む評価レポートを作成してください:
- スコア比較テーブル
- 優先度付き改善アクション
- 組織全体の改善ロードマップ（即時・短期・中期）
```

---

## プロンプト 4: エージェント改善提案の適用確認

```
以下の改善提案が適用されていることを確認してください:

1. 全エージェントに「⚠️ 対応範囲と制約」セクションが追加されているか
2. 全エージェントに「💬 使用例」セクションが追加されているか
3. .github/skills/{agent-name}/SKILL.md が作成されているか
4. .github/copilot-instructions.md が作成され、エージェントとの整合性が取れているか
5. .github/instructions/bicep.instructions.md が作成されているか
6. .github/instructions/terraform.instructions.md が作成されているか
7. .github/instructions/policy.instructions.md が作成されているか

各項目について改善後のスコアを再評価し、全エージェントが 28/35 以上を達成しているか確認してください。
```

---

## プロンプト 5: 定期レビュー（四半期ごと推奨）

```
以下の定期レビューを実施してください:

1. @copilot-expert で全エージェントのスコアを再評価（35 点満点）
2. @hr-evaluation で CAF 準拠度を再評価（25 点満点）
3. Azure CAF の最新アップデート（過去 3 ヶ月）を確認し、エージェントへの反映が必要か確認
4. 新しい Azure サービス・機能でエージェントの推奨事項に更新が必要なものを列挙
5. エージェント間の整合性チェック（用語の一貫性、連携先の双方向性）

レビュー結果を EVALUATION_REPORT.md に記録し、改善が必要な場合は PR を作成してください。
```

---

## 評価結果の記録フォーマット

評価結果は `EVALUATION_REPORT.md` に以下のフォーマットで記録します:

```markdown
# エージェント評価レポート

**評価日**: {YYYY-MM-DD}
**評価者**: {エージェント名 or 担当者}

## copilot-expert フレームワーク（35 点満点）

| エージェント | フォーマット | description | 最小権限 | バウンダリ | 具体例 | Skills | Instructions | 総合 |
|---|---|---|---|---|---|---|---|---|
| cloud-strategy | /5 | /5 | /5 | /5 | /5 | /5 | /5 | /35 |
| cloud-governance | /5 | /5 | /5 | /5 | /5 | /5 | /5 | /35 |
| cloud-platform | /5 | /5 | /5 | /5 | /5 | /5 | /5 | /35 |
| cloud-operations | /5 | /5 | /5 | /5 | /5 | /5 | /5 | /35 |
| cloud-security | /5 | /5 | /5 | /5 | /5 | /5 | /5 | /35 |
| ccoe | /5 | /5 | /5 | /5 | /5 | /5 | /5 | /35 |

## hr-evaluation フレームワーク（25 点満点）

| エージェント | CAF 準拠 | 役割明確さ | 実用性 | 連携 | セキュリティ | 総合 |
|---|---|---|---|---|---|---|
| cloud-strategy | /5 | /5 | /5 | /5 | /5 | /25 |
| cloud-governance | /5 | /5 | /5 | /5 | /5 | /25 |
| cloud-platform | /5 | /5 | /5 | /5 | /5 | /25 |
| cloud-operations | /5 | /5 | /5 | /5 | /5 | /25 |
| cloud-security | /5 | /5 | /5 | /5 | /5 | /25 |
| ccoe | /5 | /5 | /5 | /5 | /5 | /25 |

## 改善アクション

| 優先度 | アクション | 対象エージェント | 期限 | 状態 |
|---|---|---|---|---|
| 高 | | | | |
| 中 | | | | |
| 低 | | | | |
```
