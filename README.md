# GitHub Copilot カスタマイズガイド

VS Code の GitHub Copilot をプロジェクトに合わせてカスタマイズするための実践ガイドです。

## このリポジトリの目的

GitHub Copilot には、プロジェクト固有のルールや知識をファイルとして定義し、AI の振る舞いをカスタマイズする機能が多数用意されています。しかし、公式ドキュメントは英語で情報が分散しており、全体像の把握が難しいのが現状です。

**本リポジトリは、これらのカスタマイズ手法を日本語で体系的にまとめたものです。**

### スコープ

- **対象:** VS Code + GitHub Copilot（Chat / Agent モード）
- **情報源:** VS Code 公式ドキュメント（2025年7月時点）
- **言語:** 日本語（マスターリファレンスは英語版あり）

---

## ドキュメント一覧

| # | ドキュメント | 内容 |
|---|------------|------|
| 00 | [カスタマイズ概要](docs/00_overview.md) | 6つのカスタマイズ手法の全体像・優先度ガイド |
| 01 | [カスタム指示](docs/01_custom-instructions.md) | `copilot-instructions.md` / `*.instructions.md` / `AGENTS.md` の使い方 |
| 02 | [プロンプトファイル](docs/02_prompt-files.md) | `*.prompt.md` による再利用可能なチャット指示 |
| 03 | [カスタムエージェント](docs/03_custom-agents.md) | `*.agent.md` で専門AIアシスタントを定義 |
| 04 | [MCPサーバー](docs/04_mcp-servers.md) | 外部ツール・API・DBをCopilotに接続 |
| 05 | [エージェントフック](docs/05_hooks.md) | エージェント動作に連動した自動コマンド実行 |
| 06 | [Tips & ベストプラクティス](docs/06_tips.md) | コンテキストエンジニアリング・実践ワークフロー |

> 00 → 06 の順に読むと体系的に理解できますが、興味のあるトピックから読んでも問題ありません。

---

## マスターリファレンス

実際のプロジェクトで Copilot カスタム設定ファイルを生成する際に、**AI に読ませるための仕様書** です。

| ファイル | 言語 |
|---------|------|
| [custom-copilot_ja.md](master/custom-copilot_ja.md) | 日本語 |
| [custom-copilot_en.md](master/custom-copilot_en.md) | English |

### 使い方

1. マスターリファレンスをプロジェクトの `copilot-instructions.md` やチャットコンテキストに添付  
2. AI に「このプロジェクトに合った Copilot カスタム設定を生成して」と依頼  
3. AI がマスターリファレンスの仕様に従い、プロジェクト構造を分析して設定ファイル群を生成

```text
例: チャットで以下のように使う
───────────────────────────
このファイルを参照して、本プロジェクトに最適な
GitHub Copilot カスタム設定ファイル一式を生成してください。
### master/custom-copilot_ja.md の中身を貼り付ける.          ###
### またはプロジェクト内に置いた custom-copilot_ja.md にリンク. ###
───────────────────────────
```

---

## リポジトリ構成

```
├── README.md                          ← このファイル
├── docs/
│   ├── 00_overview.md 〜 06_tips.md   ← 解説ドキュメント（7本）
│   └── resources/
│       ├── diagram/                   ← Mermaid ソース（.mmd）
│       └── images/                    ← レンダリング済み SVG
├── master/
│   ├── custom-copilot_ja.md           ← マスターリファレンス（日本語）
│   └── custom-copilot_en.md           ← マスターリファレンス（英語）
└─── scripts/
    └── render-diagrams.sh             ← ダイアグラム描画スクリプト
```

---

## ライセンス

本リポジトリは [BSD 3-Clause License](LICENSE) のもとで公開されています。

## 免責事項

本ドキュメントは VS Code 公式ドキュメント（2025年7月時点）を基に作成した初版です。内容は AI と人間によるレビューを経ていますが、最新情報は [公式ドキュメント](https://code.visualstudio.com/docs/copilot/customization/overview) をご確認ください。


リポジトリmain: 
https://github.com/taogya/GithubCopilotCustom