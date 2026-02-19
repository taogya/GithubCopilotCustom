# GitHub Copilot カスタマイズ マスターリファレンス

> **このファイルの用途:** AIがプロジェクトに適した GitHub Copilot カスタム設定ファイル群を自動生成するためのリファレンス。
> 人間向けの解説ではなく、AI が参照してファイルを正確に生成するための仕様書です。
>
> **使用方法:** プロジェクトを分析した上で、このファイルの仕様に従ってカスタム設定ファイルを生成してください。

---

## 1. ファイル一覧と配置ルール

```
project-root/
├── .github/
│   ├── copilot-instructions.md          # 1.1 常時適用カスタム指示
│   ├── copilot-hooks.json               # 1.6 エージェントフック
│   ├── instructions/
│   │   └── *.instructions.md            # 1.2 スコープ付き指示（デフォルト保存先）
│   ├── prompts/
│   │   └── *.prompt.md                  # 1.3 プロンプトファイル
│   ├── agents/
│   │   └── *.agent.md                   # 1.4 カスタムエージェント
│   └── skills/
│       └── <skill-name>/
│           ├── SKILL.md                 # 1.5 エージェントスキル
│           ├── scripts/                 # スキル用スクリプト
│           └── templates/               # スキル用テンプレート
├── .vscode/
│   ├── mcp.json                         # 1.7 MCPサーバー設定
│   └── settings.json                    # 1.8 VS Code設定（Copilot関連）
├── AGENTS.md                            # 1.9 常時適用エージェント指示
├── CLAUDE.md                            # 1.10 Claude互換指示ファイル
└── src/
    └── *.instructions.md                # 1.2 スコープ付き指示（任意の場所にも配置可）
```

---

## 1.1 copilot-instructions.md

- **場所:** `.github/copilot-instructions.md`
- **適用:** 全チャットリクエスト・エージェントモードに常時適用（エディタ上のインライン提案には非適用）
- **形式:** Markdown（フロントマターなし）
- **文字数:** 簡潔に（長すぎるとノイズになる。目安: 500行以内）

### 記載すべき内容

1. **技術スタック**（言語、フレームワーク、主要ライブラリとバージョン）
2. **コーディング規約**（命名規則、フォーマット、禁止パターン）
3. **アーキテクチャ方針**（ディレクトリ構造、レイヤリング、依存方向）
4. **テスト方針**（フレームワーク、カバレッジ基準、テスト命名）
5. **プロジェクト固有の参照ドキュメント**（`[](path)` 形式でリンク）
6. **禁止事項**（`any`型禁止、classコンポーネント禁止など）

### テンプレート

```markdown
# プロジェクト指示

## 技術スタック
- 言語: {language} {version}
- フレームワーク: {framework} {version}
- テスト: {test_framework}
- スタイリング: {styling_approach}
- パッケージマネージャー: {package_manager}

## コーディング規約
- {convention_1}
- {convention_2}
- {convention_3}

## アーキテクチャ
- {architecture_pattern}
- ディレクトリ構造: [](./docs/ARCHITECTURE.md)

## 禁止事項
- {prohibition_1}
- {prohibition_2}

## テスト方針
- フレームワーク: {test_framework}
- カバレッジ基準: {coverage_criteria}
- テスト命名: {test_naming_convention}
```

---

## 1.2 .instructions.md（スコープ付き指示）

- **場所:** `.github/instructions/`（デフォルト）または任意のディレクトリ
- **適用:** `applyTo` globパターンにマッチするファイルを操作するチャットリクエスト
- **形式:** YAML フロントマター + Markdown本文
- **配置設定:** `github.copilot.chat.instructionFilesLocations` で検索パスをカスタマイズ可能

### フロントマター仕様

```yaml
---
applyTo: "glob-pattern"    # 必須: 適用対象のファイルパターン
---
```

### applyTo パターン例

| パターン | 適用対象 |
|---------|---------|
| `**/*.ts` | 全TypeScriptファイル |
| `**/*.test.ts` | 全テストファイル |
| `src/api/**` | src/api配下の全ファイル |
| `**/*.{ts,tsx}` | 全TS/TSXファイル |
| `*.md` | ルート直下のMarkdown |
| `**/*.css` | 全CSSファイル |

### テンプレート

```markdown
---
applyTo: "{glob_pattern}"
---
- {instruction_1}
- {instruction_2}
- {instruction_3}
```

### 生成ルール

- プロジェクトの主要ディレクトリ・ファイルタイプごとに1ファイル作成を検討
- ファイル名はスコープがわかる命名にする（例: `api-guidelines.instructions.md`, `test-rules.instructions.md`）
- テスト用、API用、コンポーネント用、スタイル用など、役割別に分割

---

## 1.3 .prompt.md（プロンプトファイル）

- **場所:** `.github/prompts/`
- **呼び出し:** チャットで `/ファイル名`（拡張子なし）
- **形式:** YAML フロントマター（任意） + Markdown本文
- **配置設定:** `chat.promptFilesLocations` でカスタマイズ可能

### フロントマター仕様

```yaml
---
description: "説明文"           # 任意: スラッシュコマンド一覧で表示
tools:                          # 任意: 使用可能ツールを制限
  - name: editFiles
  - name: runInTerminal
  - name: readFile
  - name: codebase
---
```

### 使用可能な変数

| 変数 | 展開内容 |
|------|---------|
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
以下を参照：
[](../../path/to/file.md)
```

`[]()` 形式でプロジェクト内ファイルをコンテキストとして添付可能。

### テンプレート

```markdown
---
description: "{description}"
tools:
  - name: {tool_1}
  - name: {tool_2}
---
# {task_title}

対象: ${file}

{task_instructions}
```

### よく作成されるプロンプトファイル

| ファイル名 | 用途 |
|-----------|------|
| `review.prompt.md` | コードレビュー |
| `test.prompt.md` | テスト生成 |
| `refactor.prompt.md` | リファクタリング |
| `doc.prompt.md` | ドキュメント生成 |
| `commit.prompt.md` | コミットメッセージ生成 |
| `migrate.prompt.md` | ライブラリ移行 |
| `debug.prompt.md` | デバッグ支援 |
| `security.prompt.md` | セキュリティチェック |

---

## 1.4 .agent.md（カスタムエージェント）

- **場所:** `.github/agents/`
- **呼び出し:** Chat の Agents ドロップダウンから選択、または `@ファイル名` でメンション
- **形式:** YAML フロントマター + Markdown本文（ペルソナ・指示）
- **配置設定:** `chat.agentFilesLocations` でカスタマイズ可能

### フロントマター仕様

```yaml
---
# 基本
tools:                              # 任意: 使用可能ツールの配列
  - name: editFiles
  - name: runInTerminal
  - name: readFile
  - name: codebase
description: "エージェントの説明"   # 任意: 一覧で表示される説明
name: "表示名"                      # 任意: ファイル名と異なる表示名
model: "gpt-4o"                     # 任意: 使用モデル指定

# エージェント間連携
handoffs:                           # 任意: ハンドオフ先エージェント
  - agent-name-1
  - agent-name-2
agents:                             # 任意: サブエージェント
  - sub-agent-1

# MCP連携
mcp-servers:                        # 任意: 使用するMCPサーバー
  - server-name

# 高度な設定
argument-hint: "レビュー対象を指定"  # 任意: 呼び出し時のヒントテキスト
user-invokable: true                # 任意: ユーザーが直接呼び出し可能か
disable-model-invocation: false     # 任意: モデルによる自動呼び出しを無効化
target: "agent"                     # 任意: ターゲットモード
---
```

### 本文の構造

```markdown
# あなたの役割
{persona_description}

# ルール
- {rule_1}
- {rule_2}

# ワークフロー
1. {step_1}
2. {step_2}
3. {step_3}

# 出力形式
{output_format_description}
```

### テンプレート

```markdown
---
tools:
  - name: {tool_1}
  - name: {tool_2}
description: "{description}"
handoffs:
  - {handoff_agent_1}
---

# あなたの役割
あなたは{role_description}です。

# ルール
- {rule_1}
- {rule_2}
- {rule_3}

# ワークフロー
1. {workflow_step_1}
2. {workflow_step_2}
3. {workflow_step_3}

# 出力形式
- {output_format}
```

### 主要ビルトインツール一覧

| ツール名 | 機能 |
|---------|------|
| `editFiles` | ファイル編集 |
| `createFile` | ファイル作成 |
| `readFile` | ファイル読み取り |
| `runInTerminal` | ターミナルコマンド実行 |
| `codebase` | コードベース検索 |
| `searchResults` | Web検索結果取得 |
| `fetch` | URL取得 |
| `githubRepo` | GitHubリポジトリ操作 |
| `usages` | シンボル使用箇所検索 |
| `testFailure` | テスト失敗情報 |

---

## 1.5 SKILL.md（エージェントスキル）

- **場所:** `.github/skills/<skill-name>/SKILL.md`
- **配置設定:** `chat.agentSkillsLocations` でカスタマイズ可能
- **呼び出し:** エージェントがスキルを使用 / `/skill-name` スラッシュコマンド

### ディレクトリ構造

```
.github/skills/<skill-name>/
├── SKILL.md          # スキル定義（必須）
├── scripts/          # 実行スクリプト（任意）
│   └── run.sh
├── templates/        # テンプレート（任意）
│   └── template.yaml
└── resources/        # リソース（任意）
    └── schema.json
```

### SKILL.md のフロントマター

```yaml
---
name: "スキル名"
description: "スキルの説明"
---
```

### テンプレート

```markdown
---
name: "{skill_name}"
description: "{skill_description}"
---
# {skill_title}

{skill_instructions}

## 使用するスクリプト
- `scripts/{script_name}` - {script_description}

## テンプレート
- `templates/{template_name}` - {template_description}
```

---

## 1.6 copilot-hooks.json（エージェントフック）

- **場所:** `.github/copilot-hooks.json`
- **機能:** エージェントのライフサイクルイベントにシェルコマンドを紐付け
- **注意:** Preview機能。組織ポリシーで無効化可能。

### JSON構造

```jsonc
{
  "hooks": {
    "イベント名": [
      {
        "type": "command",           // 必須: "command" 固定
        "command": "シェルコマンド",  // 必須: 実行するコマンド
        "timeout": 30,               // 任意: タイムアウト秒数
        "cwd": "作業ディレクトリ",   // 任意: 作業ディレクトリ
        "env": {                     // 任意: 環境変数
          "KEY": "value"
        },
        "windows": {                 // 任意: Windows固有の上書き
          "command": "windows-cmd"
        },
        "linux": {                   // 任意: Linux固有の上書き
          "command": "linux-cmd"
        },
        "osx": {                     // 任意: macOS固有の上書き
          "command": "osx-cmd"
        }
      }
    ]
  }
}
```

### フックイベント一覧

| イベント | タイミング | 用途例 |
|---------|-----------|--------|
| `SessionStart` | セッション開始時 | 環境チェック、依存関係確認 |
| `UserPromptSubmit` | ユーザー送信時 | 入力バリデーション |
| `PreToolUse` | ツール実行前 | 危険な操作のブロック |
| `PostToolUse` | ツール実行後 | lint / テスト自動実行 |
| `PreCompact` | コンテキスト圧縮前 | 重要情報の保存 |
| `SubagentStart` | サブエージェント開始時 | ログ記録 |
| `SubagentStop` | サブエージェント終了時 | 結果検証 |
| `Stop` | セッション終了時 | クリーンアップ |

### PreToolUse の実行許可制御

`PreToolUse` フックでは、stdout に JSON を出力してツール実行を制御可能:

```json
{"permissionDecision": "allow"}
```

| 値 | 動作 |
|----|------|
| `"allow"` | ツール実行を許可 |
| `"deny"` | ツール実行を拒否 |
| `"ask"` | ユーザーに確認を求める |

### コマンド引数

フックコマンドには自動的に引数が付与される（例: `--tool-name`, `--tool-call-id`）。

### テンプレート

```jsonc
{
  "hooks": {
    "PostToolUse": [
      {
        "type": "command",
        "command": "{post_tool_command}",
        "timeout": {timeout_seconds}
      }
    ],
    "SessionStart": [
      {
        "type": "command",
        "command": "{session_start_command}",
        "timeout": {timeout_seconds}
      }
    ]
  }
}
```

---

## 1.7 mcp.json（MCPサーバー設定）

- **場所:** `.vscode/mcp.json`
- **機能:** 外部ツール・API・データベースをCopilotに提供

### JSON構造

```jsonc
{
  "servers": {
    "サーバー名": {
      // stdio トランスポート（ローカルプロセス）
      "type": "stdio",
      "command": "実行コマンド",
      "args": ["引数1", "引数2"],
      "env": {
        "ENV_VAR": "${input:input-id}"
      }
    },
    "サーバー名2": {
      // HTTP トランスポート（リモート）
      "type": "http",
      "url": "https://example.com/mcp"
    },
    "サーバー名3": {
      // SSE トランスポート
      "type": "sse",
      "url": "https://example.com/sse"
    }
  },
  "inputs": [
    {
      "id": "input-id",
      "type": "promptString",
      "description": "入力の説明",
      "password": true
    }
  ]
}
```

### トランスポートタイプ

| タイプ | 用途 | 必須フィールド |
|--------|------|--------------|
| `stdio` | ローカルプロセス（最も一般的） | `command`, `args` |
| `http` | リモートHTTPサーバー | `url` |
| `sse` | Server-Sent Events | `url` |

### よく使われるMCPサーバー

| パッケージ | 用途 |
|-----------|------|
| `@modelcontextprotocol/server-github` | GitHub操作 |
| `@modelcontextprotocol/server-filesystem` | ファイルシステム |
| `@modelcontextprotocol/server-postgres` | PostgreSQL |
| `@modelcontextprotocol/server-sqlite` | SQLite |
| `@modelcontextprotocol/server-brave-search` | Web検索 |

### テンプレート

```jsonc
{
  "servers": {
    "{server_name}": {
      "type": "stdio",
      "command": "{command}",
      "args": ["{arg1}", "{arg2}"],
      "env": {
        "{ENV_KEY}": "${input:{input_id}}"
      }
    }
  },
  "inputs": [
    {
      "id": "{input_id}",
      "type": "promptString",
      "description": "{description}",
      "password": {is_password}
    }
  ]
}
```

---

## 1.8 VS Code 設定（Copilot関連の主要設定）

`settings.json` に記載する Copilot カスタマイズ関連の設定:

```jsonc
{
  // カスタム指示ファイルの検索パス
  "github.copilot.chat.instructionFilesLocations": [
    { ".github/instructions": "**" }
  ],

  // プロンプトファイルの検索パス
  "chat.promptFilesLocations": [
    { ".github/prompts": "**" }
  ],

  // カスタムエージェントの検索パス
  "chat.agentFilesLocations": [
    { ".github/agents": "**" }
  ],

  // エージェントスキルの検索パス
  "chat.agentSkillsLocations": [
    { ".github/skills": "**" }
  ],

  // ツール自動承認
  "chat.tools.global.autoApprove": false,            // 全ツール（デフォルト: false）
  "chat.tools.terminal.autoApprove": false,           // ターミナルコマンド
  "chat.tools.urls.autoApprove": false,               // URL取得
  "chat.tools.edits.autoApprove": false,              // ファイル編集

  // エージェント設定
  "chat.agent.enabled": true,
  "chat.agent.maxRequests": 30
}
```

---

## 1.9 AGENTS.md

- **場所:** プロジェクトルート（または任意のディレクトリ）
- **適用:** VS Codeが自動検出し、**全てのチャットリクエストに常時適用**
- **形式:** Markdown（フロントマターなし）
- **用途:** copilot-instructions.md と併用する追加指示

### テンプレート

```markdown
# エージェントルール

## コード変更ルール
- {rule_1}
- {rule_2}

## コミットルール
- {commit_rule_1}
- {commit_rule_2}

## 禁止事項
- {prohibition_1}
- {prohibition_2}
```

---

## 1.10 CLAUDE.md

- **場所:** プロジェクトルート（または任意のディレクトリ）
- **適用:** AGENTS.md と同様、全チャットリクエストに常時適用
- **形式:** Markdown
- **用途:** Claude互換の指示（`.claude/rules`, `.claude/agents`, `.claude/skills` フォルダもサポート）

---

## 2. 生成戦略ガイドライン

### 2.1 プロジェクト分析 → ファイル生成の流れ

1. **プロジェクト構造の把握**
   - 言語・フレームワーク・主要ライブラリを特定
   - ディレクトリ構造・レイヤリングを理解
   - 既存の設定ファイル（`package.json`, `tsconfig.json`, `.eslintrc` 等）を確認

2. **最低限生成すべきファイル**
   - `.github/copilot-instructions.md`（必須: プロジェクト全体指示）
   - `.github/prompts/review.prompt.md`（推奨: コードレビュー）
   - `.github/prompts/test.prompt.md`（推奨: テスト生成）

3. **プロジェクト規模に応じた追加ファイル**

| 規模 | 追加ファイル |
|------|------------|
| 小規模（〜10ファイル） | copilot-instructions.md のみで十分 |
| 中規模（〜100ファイル） | + .instructions.md（2-3ファイル）+ プロンプト（2-3ファイル） |
| 大規模（100+ファイル） | + カスタムエージェント + スキル + フック + MCP |

### 2.2 ファイル名の命名規則

| ファイルタイプ | 命名パターン | 例 |
|-------------|-------------|-----|
| `.instructions.md` | `{scope}-{purpose}.instructions.md` | `api-guidelines.instructions.md` |
| `.prompt.md` | `{action}.prompt.md` | `review.prompt.md` |
| `.agent.md` | `{role}.agent.md` | `reviewer.agent.md` |
| `SKILL.md` | ディレクトリ名が識別子 | `.github/skills/deploy/SKILL.md` |

### 2.3 品質チェックリスト

生成時に確認すべき事項:

- [ ] copilot-instructions.md に技術スタックが明記されているか
- [ ] copilot-instructions.md に禁止事項が含まれているか
- [ ] .instructions.md の applyTo パターンが正しい glob 構文か
- [ ] .prompt.md の変数が公式サポートされたもののみか（上記変数一覧参照）
- [ ] .agent.md のフロントマターのフィールド名が正しいか
- [ ] .agent.md の tools に存在するツール名のみ使用しているか
- [ ] copilot-hooks.json の JSON 構造が `hooks > イベント名 > 配列` になっているか
- [ ] mcp.json の JSON 構造が `servers > サーバー名 > 設定` になっているか
- [ ] ファイルの配置場所が正しいか（特にデフォルトパス）

---

## 3. 公式ドキュメントURL

| トピック | URL |
|---------|-----|
| カスタマイズ概要 | https://code.visualstudio.com/docs/copilot/customization/overview |
| カスタム指示 | https://code.visualstudio.com/docs/copilot/customization/custom-instructions |
| プロンプトファイル | https://code.visualstudio.com/docs/copilot/customization/prompt-files |
| カスタムエージェント | https://code.visualstudio.com/docs/copilot/customization/custom-agents |
| エージェントスキル | https://code.visualstudio.com/docs/copilot/customization/agent-skills |
| MCPサーバー | https://code.visualstudio.com/docs/copilot/customization/mcp-servers |
| フック | https://code.visualstudio.com/docs/copilot/customization/hooks |
| 言語モデル | https://code.visualstudio.com/docs/copilot/customization/language-models |
| 設定リファレンス | https://code.visualstudio.com/docs/copilot/reference/copilot-settings |
| チートシート | https://code.visualstudio.com/docs/copilot/reference/copilot-vscode-features |
| コンテキストエンジニアリング | https://code.visualstudio.com/docs/copilot/guides/context-engineering-guide |
| TDDフロー | https://code.visualstudio.com/docs/copilot/guides/test-driven-development-guide |

---

## 4. 実践例：TypeScript + React プロジェクト

以下はフル構成の例。プロジェクトの実態に合わせて取捨選択すること。

### .github/copilot-instructions.md

```markdown
# プロジェクト指示

## 技術スタック
- TypeScript 5.x + React 18
- ビルド: Vite
- テスト: Vitest + React Testing Library
- スタイリング: Tailwind CSS
- 状態管理: Zustand
- API通信: TanStack Query

## コーディング規約
- 関数コンポーネントのみ使用（classコンポーネント禁止）
- `any` 型の使用禁止（`unknown` + 型ガードを使用）
- 副作用は Custom Hook に分離
- エラーハンドリングは Result 型パターンで

## 命名規則
- コンポーネント: PascalCase
- 関数・変数: camelCase
- 定数: UPPER_SNAKE_CASE
- ファイル名: kebab-case.ts / kebab-case.tsx

## ディレクトリ構造
- `src/components/` - UIコンポーネント
- `src/hooks/` - カスタムフック
- `src/stores/` - 状態管理
- `src/api/` - API通信層
- `src/types/` - 型定義
- `src/utils/` - ユーティリティ
```

### .github/instructions/test-rules.instructions.md

```markdown
---
applyTo: "**/*.test.{ts,tsx}"
---
- テストは AAA パターン（Arrange / Act / Assert）で記述
- テスト名は日本語で記述（例: `it('ボタンクリックでカウントが増加する')` ）
- モックには vi.mock() を使用
- 非同期テストは waitFor / findBy を使用
- スナップショットテストは最小限に（ロジックテスト優先）
```

### .github/instructions/api-layer.instructions.md

```markdown
---
applyTo: "src/api/**"
---
- API関数は TanStack Query のカスタムフックとして公開する
- エラーレスポンスは AppError 型に変換する
- リクエスト/レスポンスの型は Zod スキーマで定義・バリデーション
- 環境変数から BASE_URL を取得する（ハードコード禁止）
```

### .github/prompts/review.prompt.md

```markdown
---
description: "コードレビュー（バグ・パフォーマンス・可読性・セキュリティ）"
tools:
  - name: readFile
  - name: codebase
---
以下の観点で ${file} をレビューしてください：

1. **バグリスク**: null/undefined、境界値、競合状態
2. **パフォーマンス**: 不要な再レンダリング、メモリリーク
3. **可読性**: 命名、関数の長さ、ネスト深度
4. **セキュリティ**: XSS、機密情報のハードコード

**出力形式:**
- 🔴 Critical / 🟡 Warning / 🔵 Info
- 該当箇所、理由、修正案
```

### .github/prompts/test.prompt.md

```markdown
---
description: "テストファイルを生成"
tools:
  - name: editFiles
  - name: readFile
  - name: runInTerminal
---
${file} のテストを生成してください。

ルール:
- Vitest + React Testing Library を使用
- AAA パターン（Arrange / Act / Assert）で記述
- 正常系・異常系・エッジケースを網羅
- テスト名は日本語
- モック: 外部依存は全て vi.mock() で

生成後、`npx vitest run ${fileBasenameNoExtension}` でテストを実行して結果を確認してください。
```

### .github/agents/reviewer.agent.md

```markdown
---
tools:
  - name: readFile
  - name: codebase
  - name: usages
description: "コードレビュー専門エージェント"
---

# あなたの役割
あなたはシニアコードレビュアーです。TypeScript/React のベストプラクティスに精通しています。

# ルール
- 指摘は重大度付きで行う: 🔴 Critical / 🟡 Warning / 🔵 Info
- 指摘には必ず修正案を添える
- 良い点も1つ以上指摘する
- プロジェクトの規約（copilot-instructions.md）に準拠しているか確認する

# レビュー観点
1. バグリスク（null安全性、境界値、競合状態）
2. パフォーマンス（不要な計算、メモリリーク、再レンダリング）
3. 保守性（SOLID原則、DRY、命名）
4. セキュリティ（入力検証、認証・認可）
5. テスタビリティ（依存注入、副作用分離）
```

### .github/copilot-hooks.json

```jsonc
{
  "hooks": {
    "PostToolUse": [
      {
        "type": "command",
        "command": "npx eslint --fix --no-error-on-unmatched-pattern .",
        "timeout": 30
      }
    ],
    "SessionStart": [
      {
        "type": "command",
        "command": "node --version && npm --version",
        "timeout": 10
      }
    ]
  }
}
```

---

> **免責事項**: 本ドキュメントは VS Code 公式ドキュメント（2025年7月時点）を基に作成した初版です。内容は AI と人間によるレビューを経ていますが、最新情報は公式ドキュメントをご確認ください。
