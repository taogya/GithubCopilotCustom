# カスタムエージェント（Custom Agents）

> 特定の役割・ツール・ルールを持った「専門AIアシスタント」を定義できる。

## 概要

<img alt="カスタムエージェントの概念" src="./resources/images/03_agents_concept.svg">

## プロンプトファイルとの違い

| | プロンプトファイル `.prompt.md` | カスタムエージェント `.agent.md` |
|---|---|---|
| **呼び出し** | `/コマンド名` | Agentsドロップダウンから選択 / `@エージェント名` |
| **性質** | 単発のタスク指示 | 専門的なペルソナ（人格） |
| **ツール制御** | 任意で制限可 | 使えるツールを明示的に指定 |
| **ハンドオフ** | ❌ | ✅ 他のエージェントに委任可能 |
| **会話の継続** | 1回きり | セッション内で継続的に対話 |

## 基本セットアップ

| 項目 | 内容 |
|------|------|
| **ファイル形式** | `.agent.md`（Markdownファイル） |
| **配置場所** | `.github/agents/` |
| **呼び出し方** | Agentsドロップダウンから選択、またはチャットで `@ファイル名` |
| **VS Code設定** | `chat.agentFilesLocations` で場所をカスタマイズ可能 |

## 基本的な書き方

**ファイル:** `.github/agents/reviewer.agent.md`

```markdown
---
tools:
  - name: editFiles
  - name: readFile
  - name: codebase
description: "コードレビュー専門エージェント"
---
```

### フロントマターで使えるフィールド

| フィールド | 必須 | 説明 |
|-----------|:----:|------|
| `tools` | - | 使用可能なツールの配列 |
| `description` | - | エージェントの説明文 |
| `handoffs` | - | 委任先エージェントの配列 |
| `name` | - | 表示名（ファイル名と異なる場合） |
| `model` | - | 使用するモデルの指定 |
| `agents` | - | サブエージェントの配列 |
| `mcp-servers` | - | 使用するMCPサーバー |
| `argument-hint` | - | 呼び出し時のヒントテキスト |

### 本文の例

```markdown
# あなたの役割
あなたはシニアコードレビュアーです。

# レビュー観点
1. バグリスク（null安全性、境界値、競合状態）
2. パフォーマンス（不要な計算、メモリリーク）
3. 保守性（SOLID原則、DRY、命名）
4. セキュリティ（入力検証、認証・認可）

# 出力形式
- 問題の重大度: 🔴 Critical / 🟡 Warning / 🔵 Info
- 該当コード箇所
- 理由
- 修正案
```

→ Agentsドロップダウンから `reviewer` を選択、またはチャットで `@reviewer このPRをレビューして` と呼び出す

## ハンドオフ（エージェント間の委任）

エージェント同士が連携できる。

```markdown
---
tools:
  - name: editFiles
  - name: runInTerminal
description: "TDD実装エージェント"
handoffs:
  - tester
  - reviewer
---

# あなたの役割
あなたはTDD実装エンジニアです。

# ワークフロー
1. テストを先に書く → @tester に委任
2. テストが通る最小限のコードを実装
3. リファクタリング
4. レビュー依頼 → @reviewer に委任
```

<img alt="ハンドオフのシーケンス" src="./resources/images/03_agents_handoff.svg">

## エージェントスキル（SKILL.md）

エージェントに「スキル」としてまとまった機能を持たせる。

```
.github/skills/
└── deploy/
    ├── SKILL.md          ← スキル定義
    ├── scripts/
    │   └── deploy.sh     ← 実行スクリプト
    └── templates/
        └── config.yaml   ← テンプレート
```

**SKILL.md の例:**

```markdown
---
name: deploy
description: "アプリケーションのデプロイを実行"
---
# デプロイスキル
scripts/deploy.sh を使ってデプロイを実行します。
環境変数 DEPLOY_ENV で対象環境を指定してください。
```

## 実用例

| エージェント | 用途 |
|-------------|------|
| `@reviewer` | コードレビュー |
| `@tester` | テスト作成・TDD |
| `@architect` | 設計レビュー・アーキテクチャ判断 |
| `@docs` | ドキュメント生成・更新 |
| `@migrator` | ライブラリ移行・アップグレード |
| `@security` | セキュリティ診断 |

## 公式ドキュメント

- [Custom agents](https://code.visualstudio.com/docs/copilot/customization/custom-agents)
- [Agent Skills](https://code.visualstudio.com/docs/copilot/customization/agent-skills)
- [Subagents](https://code.visualstudio.com/docs/copilot/agents/subagents)

---

> **免責事項**: 本ドキュメントは VS Code 公式ドキュメント（2025年7月時点）を基に作成した初版です。内容は AI と人間によるレビューを経ていますが、最新情報は公式ドキュメントをご確認ください。

---

**← 前へ** [プロンプトファイル](./02_prompt-files.md) | **次へ →** [MCPサーバー](./04_mcp-servers.md)
