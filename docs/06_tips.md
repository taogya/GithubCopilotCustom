# Tips & ベストプラクティス

> カスタマイズを最大限に活かすための実践的なワークフローとコツ。

## コンテキストエンジニアリング（3ステップ）

公式ガイドが推奨する、AIとの効果的な協業フロー。

<img alt="コンテキストエンジニアリング3ステップ" src="./resources/images/06_tips_steps.svg">

### ① プロジェクトコンテキストを整備

`copilot-instructions.md` でプロジェクトの全体像を伝える:

```markdown
# プロジェクトコンテキスト
以下のファイルを参照してプロジェクトを理解すること:
- [](./docs/PRODUCT.md) - プロダクト概要・機能仕様
- [](./docs/ARCHITECTURE.md) - アーキテクチャ・技術構成
- [](./CONTRIBUTING.md) - 開発規約・ブランチ戦略
```

### ② カスタム Plan エージェントで設計

```markdown
<!-- .github/agents/planner.agent.md -->
---
tools:
  - readFile
  - codebase
description: "実装の計画を立てるエージェント"
---
あなたは設計エンジニアです。
計画テンプレートに従って、実装計画を策定してください。
[](../../docs/plan-template.md)
```

### ③ TDD エージェントで実装

```markdown
<!-- .github/agents/tdd.agent.md -->
---
tools:
  - editFiles
  - runInTerminal
description: "TDD実装エージェント"
handoffs:
  - label: レビュー依頼
    agent: reviewer
    prompt: 上記の実装をレビューしてください。
---
テスト駆動で実装する:
1. 🔴 Red: 失敗するテストを書く
2. 🟢 Green: テストが通る最小コードを書く
3. 🔵 Refactor: リファクタリング
```

## カスタマイズファイルの組み合わせ例

<img alt="カスタマイズファイルの組み合わせ" src="./resources/images/06_tips_combo.svg">

## よくある導入パターン

### ミニマル構成（まずはこれ）

```
.github/
└── copilot-instructions.md    ← 技術スタック + 規約のみ
```



### スタンダード構成

```
.github/
├── copilot-instructions.md    ← プロジェクト規約
├── prompts/
│   ├── review.prompt.md       ← コードレビュー
│   └── test.prompt.md         ← テスト生成
└── agents/
    └── tdd.agent.md           ← TDD実装
```



### フル構成

```
.github/
├── copilot-instructions.md
├── prompts/
│   ├── review.prompt.md
│   ├── test.prompt.md
│   └── migrate.prompt.md
├── agents/
│   ├── planner.agent.md
│   ├── tdd.agent.md
│   └── reviewer.agent.md
├── copilot-hooks.json
└── skills/
    └── deploy/SKILL.md
.vscode/
└── mcp.json
src/
├── api.instructions.md        ← applyTo: src/api/**
└── components.instructions.md ← applyTo: src/components/**
```

## 効果的な指示の書き方

| ✅ 良い書き方 | ❌ 避けるべき書き方 |
|-------------|----------------|
| 「React 18の関数コンポーネントを使う」 | 「良いコードを書いて」 |
| 「Vitestでテストを書く。AAA パターン」 | 「テストもお願い」 |
| 「エラーは Result 型で。try-catch 禁止」 | 「エラー処理をちゃんとやって」 |
| 「日本語コメント。JSDoc必須」 | 「コメントを書いて」 |

## モデル選択のコツ

| 場面 | おすすめ |
|------|---------|
| 素早いコード補完 | Auto（自動選択に任せる） |
| 複雑な設計・計画 | Claude Sonnet / GPT-4o |
| 大量のコード生成 | Claude Sonnet |
| 簡単な質問・修正 | GPT-4o mini |

VS Code設定でデフォルトモデルを変更可能。チャット入力欄のモデルピッカーで都度変更も可。

## トラブルシューティング

| 症状 | 対処法 |
|------|--------|
| カスタム指示が効かない | ファイルパスを確認（`.github/copilot-instructions.md`） |
| プロンプトファイルが表示されない | `chat.promptFilesLocations` 設定を確認 |
| MCPサーバーが接続できない | コマンドパスの確認、`/mcp` で状態確認 |
| 指示を無視される | 指示が長すぎる可能性。簡潔に書き直す |
| エージェントが使えない | `chat.agent.enabled: true` を確認 |

→ 詳細: [Chat Debug view](https://code.visualstudio.com/docs/copilot/chat/chat-debug-view) でAIのリクエスト・レスポンスを検査

## 公式ドキュメント

- [Best practices for using AI](https://code.visualstudio.com/docs/copilot/best-practices)
- [Context engineering flow](https://code.visualstudio.com/docs/copilot/guides/context-engineering-guide)
- [TDD flow in VS Code](https://code.visualstudio.com/docs/copilot/guides/test-driven-development-guide)
- [Prompt engineering](https://code.visualstudio.com/docs/copilot/guides/prompt-engineering-guide)

---

> **免責事項**: 本ドキュメントは VS Code 公式ドキュメント（2025年7月時点）を基に作成した初版です。内容は AI と人間によるレビューを経ていますが、最新情報は公式ドキュメントをご確認ください。

---

**← 前へ** [フック](./05_hooks.md) | **トップへ →** [概要](./00_overview.md)
