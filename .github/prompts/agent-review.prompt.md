---
name: agent-review
description: Copilot カスタマイズファイル（5 種類）の品質評価を実施するための標準プロンプト
---

# Copilot カスタマイズファイル品質評価プロンプト

このプロンプトファイルは `.github/` 配下のすべての Copilot カスタマイズファイルを体系的に評価するために使用します。

---

## 使い方

このプロンプトファイルを使用するには、以下のいずれかの方法を選択してください:

1. **エージェント単体評価**: `@copilot-expert` に評価を依頼
2. **CAF 準拠評価**: `@hr-evaluation` に評価を依頼
3. **全ファイル横断評価**: 以下のプロンプトをそのまま使用

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
3. .github/skills/{agent-name}/SKILL.md が作成され、name・description の YAML フロントマターを含むか
4. .github/copilot-instructions.md が作成され、エージェントとの整合性が取れているか
5. .github/instructions/bicep.instructions.md が作成され、applyTo パターンが正しいか
6. .github/instructions/terraform.instructions.md が作成され、applyTo パターンが正しいか
7. .github/instructions/policy.instructions.md が作成され、applyTo パターンが正しいか

各項目について改善後のスコアを再評価し、全エージェントが 28/35 以上を達成しているか確認してください。
```

---

## プロンプト 5: SKILL.md フロントマター検証

```
@copilot-expert .github/skills/ 配下の全 SKILL.md ファイルを評価してください。

確認事項:
1. YAML フロントマターが存在するか（--- で囲まれた冒頭ブロック）
2. name フィールドが存在し、対応するエージェント名と一致しているか
3. description フィールドが存在し、スキルの内容を適切に説明しているか（50 文字以上を推奨）
4. スキルの内容がエージェント本体（.agent.md）の記述と整合しているか
5. エージェント本体から .github/skills/{agent-name}/SKILL.md への参照リンクがあるか

問題があれば、修正後の YAML フロントマター案を提示してください。
```

---

## プロンプト 6: .instructions.md applyTo 検証

```
@copilot-expert .github/instructions/ 配下の全 .instructions.md ファイルを評価してください。

確認事項:
1. YAML フロントマターに applyTo フィールドが存在するか
2. applyTo の glob パターンが対象ファイルを正しく網羅しているか
3. glob パターンが意図せず広すぎる / 狭すぎる範囲を指定していないか
4. 各ファイルの内容が applyTo の対象ファイル種別に合致しているか
5. 不足している技術領域（例: Bicep, Terraform, Policy JSON 以外）がないか確認する

問題があれば、修正後の frontmatter と glob パターン案を提示してください。
```

---

## プロンプト 7: 全 Copilot カスタマイズファイル横断評価

```
@copilot-expert .github/ 配下のすべての Copilot カスタマイズファイルを横断的に評価してください。

評価対象ファイル種別:
- .agent.md   : .github/agents/ 配下の全ファイル
- SKILL.md    : .github/skills/*/SKILL.md の全ファイル
- copilot-instructions.md : .github/copilot-instructions.md
- .instructions.md : .github/instructions/*.instructions.md の全ファイル
- .prompt.md  : .github/prompts/*.prompt.md の全ファイル

横断評価の観点:
1. ファイル種別ごとの必須フォーマット（YAML フロントマター）の準拠状況
2. エージェント ↔ SKILL.md の対応関係（全エージェントに対応 SKILL.md が存在するか）
3. instructions ファイルの applyTo と実際のリポジトリ内ファイル種別の整合性
4. copilot-instructions.md の記述と各エージェント定義の矛盾がないか
5. prompt.md の name・description の適切さ

出力フォーマット:
- 種別ごとのファイル一覧と検証結果（OK/要改善）
- 不備がある場合の優先度付き改善アクションリスト
```

---

## プロンプト 8: 定期レビュー（四半期ごと推奨）

```
以下の定期レビューを実施してください:

1. @copilot-expert で全エージェントのスコアを再評価（35 点満点）
2. @hr-evaluation で CAF 準拠度を再評価（25 点満点）
3. Azure CAF の最新アップデート（過去 3 ヶ月）を確認し、エージェントへの反映が必要か確認
4. 新しい Azure サービス・機能でエージェントの推奨事項に更新が必要なものを列挙
5. エージェント間の整合性チェック（用語の一貫性、連携先の双方向性）
6. SKILL.md の内容がエージェント本体と乖離していないか確認

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

## SKILL.md フロントマター検証結果

| スキルファイル | name | description | 整合性 | 状態 |
|---|---|---|---|---|
| ccoe/SKILL.md | OK/NG | OK/NG | OK/NG | ✅/❌ |
| cloud-governance/SKILL.md | OK/NG | OK/NG | OK/NG | ✅/❌ |
| cloud-operations/SKILL.md | OK/NG | OK/NG | OK/NG | ✅/❌ |
| cloud-platform/SKILL.md | OK/NG | OK/NG | OK/NG | ✅/❌ |
| cloud-security/SKILL.md | OK/NG | OK/NG | OK/NG | ✅/❌ |
| cloud-strategy/SKILL.md | OK/NG | OK/NG | OK/NG | ✅/❌ |
| copilot-expert/SKILL.md | OK/NG | OK/NG | OK/NG | ✅/❌ |
| hr-evaluation/SKILL.md | OK/NG | OK/NG | OK/NG | ✅/❌ |

## 改善アクション

| 優先度 | アクション | 対象ファイル | 期限 | 状態 |
|---|---|---|---|---|
| 高 | | | | |
| 中 | | | | |
| 低 | | | | |
```
