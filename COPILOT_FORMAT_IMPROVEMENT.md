# GitHub Copilot フォーマット改善提案レポート

**評価日**: 2026-03-25  
**評価フレームワーク**: `@copilot-expert`（35 点満点）+ `@hr-evaluation`（25 点満点）  
**評価対象**: `.github/agents/` 配下の全 8 エージェント

---

## 1. エージェント評価結果（copilot-expert フレームワーク、35 点満点）

### 評価前スコア（初期状態）

| エージェント | フォーマット | description | 最小権限 | バウンダリ | 具体例 | Skills | Instructions | 総合 | 合否 |
|---|---|---|---|---|---|---|---|---|---|
| `cloud-strategy` | 5/5 | 4/5 | 4/5 | 2/5 | 3/5 | 1/5 | 1/5 | **20/35** | ❌ |
| `cloud-governance` | 5/5 | 4/5 | 3/5 | 2/5 | 4/5 | 1/5 | 1/5 | **20/35** | ❌ |
| `cloud-platform` | 5/5 | 4/5 | 3/5 | 2/5 | 5/5 | 1/5 | 1/5 | **21/35** | ❌ |
| `cloud-operations` | 5/5 | 4/5 | 3/5 | 2/5 | 4/5 | 1/5 | 1/5 | **20/35** | ❌ |
| `cloud-security` | 5/5 | 4/5 | 3/5 | 2/5 | 4/5 | 1/5 | 1/5 | **20/35** | ❌ |
| `ccoe` | 5/5 | 4/5 | 3/5 | 2/5 | 3/5 | 1/5 | 1/5 | **19/35** | ❌ |
| `copilot-expert` | 5/5 | 5/5 | 5/5 | 4/5 | 5/5 | 1/5 | 1/5 | **26/35** | ❌ |
| `hr-evaluation` | 4/5 | 5/5 | 3/5 | 3/5 | 3/5 | 1/5 | 1/5 | **20/35** | ❌ |

> **合否基準**: 28/35 以上 = ✅ 合格、28 未満 = ❌ 要改善

**結論**: 全エージェントが基準を下回っており、主な原因は以下の 3 点:
1. **Agent Skills 連携 (観点 6)**: `.github/skills/` ディレクトリが未作成 → 全員 1/5
2. **Custom Instructions 活用 (観点 7)**: `.github/copilot-instructions.md` が未作成 → 全員 1/5
3. **バウンダリ定義 (観点 4)**: 「やらないこと」セクションが明文化されていない → 全員 2/5

### 評価後スコア（フェーズ 1 改善適用後）

フェーズ 1 で SKILL.md 作成・エージェント更新・instructions 作成を適用:

| エージェント | フォーマット | description | 最小権限 | バウンダリ | 具体例 | Skills | Instructions | 総合 | 合否 |
|---|---|---|---|---|---|---|---|---|---|
| `cloud-strategy` | 5/5 | 4/5 | 4/5 | **4/5** | **4/5** | **4/5** | **4/5** | **29/35** | ✅ |
| `cloud-governance` | 5/5 | 4/5 | 3/5 | **4/5** | **4/5** | **4/5** | **4/5** | **28/35** | ✅ |
| `cloud-platform` | 5/5 | 4/5 | 3/5 | **4/5** | 5/5 | **4/5** | **4/5** | **29/35** | ✅ |
| `cloud-operations` | 5/5 | 4/5 | 3/5 | **4/5** | **4/5** | **4/5** | **4/5** | **28/35** | ✅ |
| `cloud-security` | 5/5 | 4/5 | 3/5 | **4/5** | **4/5** | **4/5** | **4/5** | **28/35** | ✅ |
| `ccoe` | 5/5 | 4/5 | 3/5 | **4/5** | **4/5** | **4/5** | **4/5** | **28/35** | ✅ |
| `copilot-expert` | 5/5 | 5/5 | 5/5 | 4/5 | 5/5 | **4/5** | **4/5** | **32/35** | ✅ |
| `hr-evaluation` | 4/5 | 5/5 | 3/5 | 3/5 | 3/5 | **4/5** | **4/5** | **26/35** | ❌ |

> `hr-evaluation` は `edit` ツールを評価エージェントに付与している点（観点 3）と、バウンダリ・具体例のカバレッジ（観点 4, 5）に軽微な改善余地が残ります。

### フェーズ 2 追加改善（本 PR で適用）

フェーズ 2 で SKILL.md YAML フロントマター追加・copilot-instructions.md 更新・agent-review.prompt.md 拡張を適用:

| 変更内容 | 対象ファイル | 効果 |
|---|---|---|
| YAML フロントマター追加 | 全 8 件の SKILL.md | `name` + `description` フィールドを追加し、GitHub Copilot 正式フォーマットに準拠 |
| エージェント一覧の説明更新 | `copilot-instructions.md` | `@copilot-expert` の説明を全 5 ファイル種別を対象とする内容に修正 |
| プロンプト拡張 | `agent-review.prompt.md` | SKILL.md 検証・instructions applyTo 検証・全ファイル横断評価の 3 プロンプトを追加 |

---

## 2. hr-evaluation フレームワーク評価結果（25 点満点）

### 評価前スコア

| エージェント | CAF 準拠 | 役割明確さ | 実用性 | 連携 | セキュリティ | 総合 | 合否 |
|---|---|---|---|---|---|---|---|
| `cloud-strategy` | 5/5 | 4/5 | 4/5 | 5/5 | 4/5 | **22/25** | ✅ |
| `cloud-governance` | 5/5 | 4/5 | 5/5 | 5/5 | 4/5 | **23/25** | ✅ |
| `cloud-platform` | 5/5 | 5/5 | 5/5 | 4/5 | 5/5 | **24/25** | ✅ |
| `cloud-operations` | 5/5 | 5/5 | 5/5 | 4/5 | 3/5 | **22/25** | ✅ |
| `cloud-security` | 5/5 | 4/5 | 5/5 | 4/5 | 5/5 | **23/25** | ✅ |
| `ccoe` | 5/5 | 5/5 | 4/5 | 5/5 | 3/5 | **22/25** | ✅ |

> **合否基準**: 20/25 以上 = ✅ 良好

**結論**: CAF 準拠度・役割・実用性・連携の観点では全エージェントが高品質。  
改善の余地があるのはセキュリティ考慮（cloud-operations: 3/5、ccoe: 3/5）。

---

## 3. 適用した改善内容

### 3.1 新規作成ファイル

#### `.github/copilot-instructions.md`

リポジトリ全体のベースラインルールを定義。以下を含む:
- エージェント体系の一覧
- 共通言語・スタイル規則
- Azure CAF 共通用語・命名規則・タグ戦略
- IaC 共通ルール（Bicep/Terraform）
- セキュリティ共通方針（最小権限、シークレット管理、暗号化、監査ログ）
- エージェント間連携の基本ルール
- エージェント品質基準（copilot-expert フレームワーク参照）

#### `.github/skills/` ディレクトリ（8 ファイル）

| スキルファイル | 内容 |
|---|---|
| `cloud-strategy/SKILL.md` | 動機分類、TCO/ROI 計算、5R 分類、ロードマップテンプレート |
| `cloud-governance/SKILL.md` | ガバナンス 5 分野、推奨 Azure Policy 一覧、RBAC テンプレート、KQL クエリ集 |
| `cloud-platform/SKILL.md` | ALZ 管理グループ階層、Hub-Spoke 図、Bicep/Terraform 構成標準、IaC チェックリスト |
| `cloud-operations/SKILL.md` | Azure Monitor アーキテクチャ、SLI/SLO/エラーバジェット、アラート設計、KQL クエリ集 |
| `cloud-security/SKILL.md` | ゼロトラスト原則、Defender for Cloud プラン、Sentinel 構成、セキュリティ KQL、多層防御 |
| `ccoe/SKILL.md` | 成熟度モデル、オンボーディングワークフロー、セルフサービスカタログ、KPI、ADR テンプレート |
| `copilot-expert/SKILL.md` | 35 点スコアカード、必須フォーマット、バウンダリ定義テンプレート、使用例テンプレート |
| `hr-evaluation/SKILL.md` | 25 点スコアカード、エージェント別 CAF チェックリスト、改善ロードマップテンプレート |

> **フェーズ 2 で追加**: 全 8 件の SKILL.md に `name` + `description` の YAML フロントマターを追加。

#### `.github/instructions/` ディレクトリ（3 ファイル）

| インストラクションファイル | applyTo glob パターン | 内容 |
|---|---|---|
| `bicep.instructions.md` | `**/*.bicep,**/*.bicepparam,**/bicepconfig.json` | ファイル構成、必須規則、セキュリティ必須事項、CI/CD パターン |
| `terraform.instructions.md` | `**/*.tf,**/*.tfvars,**/.terraform.lock.hcl` | ファイル構成、versions.tf、locals.tf、シークレット管理、AVM 活用 |
| `policy.instructions.md` | `**/policy/**/*.json,**/*policy*.json` 等 | ポリシー定義構造、効果の段階適用、イニシアティブ構成、テスト方法 |

#### `.github/prompts/agent-review.prompt.md`

8 種類の標準評価プロンプトを収録（フェーズ 2 で 3 件追加）:
1. 単体エージェント評価（copilot-expert フレームワーク）
2. 全エージェント一括評価
3. CAF 準拠度評価（hr-evaluation フレームワーク）
4. 改善適用後の確認（SKILL.md フロントマター検証を含む）
5. **[New]** SKILL.md フロントマター検証
6. **[New]** `.instructions.md` applyTo 検証
7. **[New]** 全 Copilot カスタマイズファイル横断評価
8. 定期レビュー（四半期推奨）

### 3.2 既存エージェントへの追加

すべての CAF エージェント（cloud-strategy, cloud-governance, cloud-platform, cloud-operations, cloud-security, ccoe）に以下のセクションを追加:

#### 追加セクション 1: `## ⚠️ 対応範囲と制約`

```markdown
## ⚠️ 対応範囲と制約

### このエージェントが行うこと
- {主要タスクのリスト}

### このエージェントが行わないこと
- **{スコープ外}: → {委譲先エージェント}
- ...

### スコープ外リクエストへの対応
適切なエージェントへの案内テンプレートを含む
```

#### 追加セクション 2: `## 💬 使用例`

各エージェントに 3〜4 個の具体的な使用例を追加:
- 典型的なユースケース（入力プロンプト + 期待する出力の概要）
- KQL クエリや IaC コード例を含む具体的なシナリオ
- スコープ外リクエストへの応答例

#### 追加セクション 3: `## 参照スキル`

各エージェントのスキルファイルと関連インストラクションへのリンクを追加。

---

## 4. 改善前後の比較（観点別）

### 観点 4: バウンダリ定義

**Before（改善前）:**
```markdown
# Cloud Strategy エージェント
（バウンダリセクションなし）
## 回答時のガイドライン
1. ビジネス価値の明確化...
```
スコア: 2/5（暗黙的に理解はできるが明文化なし）

**After（改善後）:**
```markdown
## ⚠️ 対応範囲と制約

### このエージェントが行わないこと
- **技術的な実装**: IaC コードの作成 → @cloud-platform
- **ガバナンスポリシーの実装** → @cloud-governance
...

### スコープ外リクエストへの対応
⚠️ このリクエストは Cloud Strategy の対応範囲外です...
```
スコア: 4/5（明確な禁止事項と委譲先の定義）

### 観点 5: 具体例の有無

**Before（改善前）:**
- TCO テンプレートや ROI 計算式は存在
- しかし「@cloud-strategy に XXX を依頼したらどうなるか」のユーザー視点の例がない

スコア: 3/5

**After（改善後）:**
- ユーザーの入力プロンプト例（具体的な依頼文）を追加
- 期待する出力のフォーマット・内容を明示
- スコープ外リクエストへの応答例を追加

スコア: 4/5

### 観点 6: Agent Skills 連携

**Before（改善前）:**
- `.github/skills/` ディレクトリが存在しない
- スキル連携の設計なし

スコア: 1/5

**After（改善後）:**
- `.github/skills/{agent-name}/SKILL.md` を作成
- 各エージェントの本文から `## 参照スキル` セクションでリンク
- 再利用可能なテンプレート・チェックリスト・クエリ集を切り出し

スコア: 4/5

### 観点 7: Custom Instructions 活用

**Before（改善前）:**
- `.github/copilot-instructions.md` が存在しない
- `.github/prompts/` ディレクトリが存在しない

スコア: 1/5

**After（改善後）:**
- `.github/copilot-instructions.md` に組織全体のベースラインルールを定義
- エージェント固有の指示はエージェントファイルに留め、共通部分はベースラインに集約
- `.github/prompts/agent-review.prompt.md` に標準評価プロンプトを作成
- `.github/instructions/` に IaC パス向けインストラクションを作成

スコア: 4/5

---

## 5. 残存する改善余地

### hr-evaluation エージェント（26/35）

| 観点 | スコア | 課題 |
|---|---|---|
| ツールの最小権限 | 3/5 | 評価専用エージェントに `edit` ツールが付与されている。評価提案は読み取り+提示のみで十分 |
| バウンダリ定義 | 3/5 | バウンダリセクションが implicit。他メタエージェントとの違いが不明確 |
| 具体例 | 3/5 | 評価の入出力例が少ない。実際の評価レポートのサンプルがあると良い |

**推奨改善（次フェーズ）:**

```yaml
# hr-evaluation.agent.md frontmatter の改善案
tools:
  - read    # ファイル読み取り
  - search  # 関連ファイル検索
  # edit は削除（評価専用なら不要）
```

### 全エージェント共通の改善余地

1. **mcp-servers の tools 制限**: 現在 `["*"]` で全ツール許可。特定のツールに限定することでセキュリティ強化
2. **ADR（アーキテクチャ決定記録）への参照**: 各エージェントの設計判断を ADR として記録し参照する仕組み
3. **多言語対応**: 現在は日本語のみ。英語でのキーワードも description に追加すると国際チームでの活用が向上

---

## 6. 優先度付き改善アクション（完了済み）

| 優先度 | 改善アクション | 対象 | 状態 |
|---|---|---|---|
| **高** | `.github/skills/` ディレクトリと SKILL.md ファイルの作成 | 全エージェント | ✅ 完了 |
| **高** | `.github/copilot-instructions.md` の作成 | リポジトリ全体 | ✅ 完了 |
| **高** | 全エージェントへのバウンダリ定義セクション追加 | 全 CAF エージェント | ✅ 完了 |
| **高** | 全エージェントへの使用例セクション追加 | 全 CAF エージェント | ✅ 完了 |
| **中** | `.github/instructions/` の IaC インストラクション作成 | Bicep/Terraform/Policy | ✅ 完了 |
| **中** | `.github/prompts/agent-review.prompt.md` の作成 | 評価ワークフロー | ✅ 完了 |
| **低** | `hr-evaluation` の `edit` ツール削除 | hr-evaluation | ⬜ 次フェーズ |
| **低** | mcp-servers の tools フィールドを特定ツールに限定 | 全エージェント | ⬜ 次フェーズ |

---

## 7. ファイル変更サマリー

### フェーズ 1: 新規作成ファイル（13 ファイル）

```
.github/copilot-instructions.md
.github/skills/cloud-strategy/SKILL.md
.github/skills/cloud-governance/SKILL.md
.github/skills/cloud-platform/SKILL.md
.github/skills/cloud-operations/SKILL.md
.github/skills/cloud-security/SKILL.md
.github/skills/ccoe/SKILL.md
.github/skills/copilot-expert/SKILL.md
.github/skills/hr-evaluation/SKILL.md
.github/instructions/bicep.instructions.md
.github/instructions/terraform.instructions.md
.github/instructions/policy.instructions.md
.github/prompts/agent-review.prompt.md
```

### フェーズ 1: 更新ファイル（8 ファイル）

```
.github/agents/cloud-strategy.agent.md    - バウンダリ定義、使用例、参照スキルを追加
.github/agents/cloud-governance.agent.md  - バウンダリ定義、使用例、参照スキルを追加
.github/agents/cloud-platform.agent.md    - バウンダリ定義、使用例、参照スキルを追加
.github/agents/cloud-operations.agent.md  - バウンダリ定義、使用例、参照スキルを追加
.github/agents/cloud-security.agent.md    - バウンダリ定義、使用例、参照スキルを追加
.github/agents/ccoe.agent.md              - バウンダリ定義、使用例、参照スキルを追加
.github/agents/copilot-expert.agent.md    - 全 5 ファイル種別対応に拡張、参照スキルを追加
.github/agents/hr-evaluation.agent.md     - 参照スキルを追加
```

### フェーズ 2: 新規作成ファイル（0 ファイル）

フェーズ 2 では新規ファイルの作成はなく、既存ファイルの更新のみ。

### フェーズ 2: 更新ファイル（4 ファイル）

```
.github/skills/*/SKILL.md（全 8 件）       - name・description の YAML フロントマターを追加
.github/copilot-instructions.md            - @copilot-expert の説明を全 5 ファイル種別対応に修正
.github/prompts/agent-review.prompt.md     - SKILL.md 検証・instructions 検証・横断評価プロンプト追加
COPILOT_FORMAT_IMPROVEMENT.md（本ファイル） - フェーズ 2 の変更内容を反映
```

---

## 8. 注意事項

- **既存の CAF 機能・専門性は維持**: すべての既存コンテンツを保持し、新しいセクションを追加のみ
- **フォーマット面の改善のみ**: エージェントの役割・指示内容は変更なし
- **整合性の確保**: `.github/copilot-instructions.md` のベースラインと各エージェントの指示に矛盾なし
- **SKILL.md の配置**: `.github/skills/<スキル名>/SKILL.md` の命名規則に準拠
- **SKILL.md フロントマター**: 全 SKILL.md に `name` と `description` フィールドを含む YAML フロントマターを追加

---

*このドキュメントは `@copilot-expert` および `@hr-evaluation` の評価フレームワークに基づいて作成されました。*
