# プロンプトファイル（Prompt Files）

> よく使うチャット指示を `.prompt.md` に保存 → **スラッシュコマンドとして呼び出せる。**

## 概要

<img alt="プロンプトファイルの仕組み" src="./resources/images/02_prompt_flow.svg">

## 基本セットアップ

| 項目 | 内容 |
|------|------|
| **ファイル形式** | `.prompt.md`（Markdownファイル） |
| **配置場所** | `.github/prompts/` |
| **呼び出し方** | チャットで `/ファイル名` |
| **VS Code設定** | `chat.promptFilesLocations` で場所をカスタマイズ可能 |

## 基本的な書き方

**ファイル:** `.github/prompts/review.prompt.md`

```markdown
以下の観点でコードレビューしてください：

1. **バグリスク**: null/undefinedの可能性、境界値
2. **パフォーマンス**: 不要な再レンダリング、N+1クエリ
3. **可読性**: 命名、関数の長さ、ネスト深度
4. **セキュリティ**: XSS、SQLインジェクション、認証漏れ

問題がある場合は修正案も提示してください。
```

→ チャットで `/review` と打つだけで実行

## 変数・ファイル参照の活用

### 変数を使う

```markdown
---
description: "コンポーネントのテストを生成"
---
# テスト生成

対象: ${file}

以下のルールでテストを生成:
- フレームワーク: Vitest + React Testing Library
- カバレッジ: 正常系・異常系・エッジケース
- モック: 外部依存は全てモック化
```

### 使える変数

| 変数 | 内容 |
|------|------|
| `${file}` | 現在開いているファイルのフルパス |
| `${fileBasename}` | ファイル名（拡張子付き） |
| `${fileDirname}` | ファイルのディレクトリパス |
| `${fileBasenameNoExtension}` | ファイル名（拡張子なし） |
| `${selection}` / `${selectedText}` | 現在の選択テキスト |
| `${workspaceFolder}` | ワークスペースフォルダのパス |
| `${workspaceFolderBasename}` | ワークスペースフォルダ名 |
| `${input:variableName}` | 実行時にユーザー入力を求める |

### ファイル参照

```markdown
# API実装

アーキテクチャは以下を参照:
[](../../docs/ARCHITECTURE.md)

以下のパターンに従ってAPIエンドポイントを実装してください。
```

`[]()` 形式でプロジェクト内のファイルをコンテキストとして添付可能。

## ツール設定（使えるツールを制限）

```markdown
---
tools:
  - name: editFiles
  - name: runInTerminal
description: "リファクタリング用プロンプト"
---
選択したコードをリファクタリングしてください。
変更後にテストを実行して確認してください。
```

## 実用例

| ファイル名 | 用途 | 呼び出し |
|-----------|------|---------|
| `review.prompt.md` | コードレビュー | `/review` |
| `test.prompt.md` | テスト生成 | `/test` |
| `refactor.prompt.md` | リファクタリング | `/refactor` |
| `doc.prompt.md` | ドキュメント生成 | `/doc` |
| `commit.prompt.md` | コミットメッセージ生成 | `/commit` |
| `migrate.prompt.md` | マイグレーション支援 | `/migrate` |

## チャットからの保存（/savePrompt）

チャットで良い指示ができたら、その場で保存できる:

1. チャットで良い結果を得る
2. `/savePrompt` と入力
3. ファイル名をつけて保存 → `.github/prompts/` に `.prompt.md` として保存される

## 公式ドキュメント

- [Prompt files](https://code.visualstudio.com/docs/copilot/customization/prompt-files)

---

> **免責事項**: 本ドキュメントは VS Code 公式ドキュメント（2025年7月時点）を基に作成した初版です。内容は AI と人間によるレビューを経ていますが、最新情報は公式ドキュメントをご確認ください。

---

**← 前へ** [カスタム指示](./01_custom-instructions.md) | **次へ →** [カスタムエージェント](./03_custom-agents.md)
