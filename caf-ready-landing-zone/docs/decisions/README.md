# 意思決定記録（ADR）

このディレクトリには **Architecture Decision Records (ADR)** を格納します。
プロジェクトにおける重要な技術・設計上の意思決定を記録し、後からその背景・理由を追跡できるようにします。

## ADR の命名規則

```
decisions/
├── ADR-0001-use-bicep-over-terraform.md
├── ADR-0002-hub-spoke-topology.md
├── ADR-0003-avm-pattern-modules.md
└── ...
```

## ADR テンプレート

```markdown
# ADR-XXXX: {タイトル}

- **ステータス**: Proposed | Accepted | Deprecated | Superseded
- **日付**: YYYY-MM-DD
- **決定者**: {チーム名 / 個人名}

## コンテキスト

{意思決定が必要になった背景・課題}

## 決定事項

{何を決定したか}

## 理由

{その決定を選んだ理由・トレードオフの考慮}

## 結果

{この決定によって生じる影響（ポジティブ・ネガティブ）}

## 代替案

{検討したが採用しなかった選択肢とその理由}
```

## 初期 ADR 一覧

| ADR | タイトル | ステータス |
|---|---|---|
| ADR-0001 | IaC ツールとして Bicep を採用 | Accepted |
| ADR-0002 | Hub-Spoke ネットワークトポロジの採用 | Accepted |
| ADR-0003 | AVM Pattern Modules の活用 | Accepted |
