# CC Marketplace for Claude Code

[English version](README.md)

Claude Code マーケットプレイスバンドル（開発必須プラグイン集）

## プラグイン

- **statusline**: ブランチ・モデル・コスト・所要時間・変更を表示するステータスライン
- **gh**: インテリジェントな PR 自動作成
- **git**: Git-flow ワークフロー自動化（ブランチ作成、Conventional Commit）

## インストール

```bash
/plugin marketplace add setouchi-h/cc-marketplace
/plugin install statusline@cc-marketplace
/plugin install gh@cc-marketplace
/plugin install git@cc-marketplace
```

## 使い方

### statusline

Claude Code のプロンプトに豊富なセッション情報を表示するプラグインです。

**表示内容:**
- 🌿 現在の git ブランチ
- 🤖 AI モデル（例: Sonnet 4.5）
- 💰 セッションコスト（USD）
- ⏱️ 経過時間（例: 1m49s）
- 📝 変更行数（+10/-2）
- 💬 名言（オプション、5分ごとに更新）

**必要要件:**
- `jq` のインストールが必須（JSON 解析用）
- `curl` はオプション（名言機能用）

**インストール:**
```bash
# ステップ 1: プラグインのインストール
/plugin install statusline@cc-marketplace

# ステップ 2: インストーラの実行
/statusline:install-statusline

# オプション: 名言なしでインストール
/statusline:install-statusline --no-quotes

# フルセッション前にプレビュー
/statusline:preview-statusline
```

インストーラは `~/.claude/scripts/statusline.sh` を作成し、`~/.claude/settings.json` を自動設定します。

### gh
```bash
/gh:create-pr                         # 現在のブランチから PR 作成
/gh:create-pr -d -b develop          # develop に対するドラフト PR
```

### git
```bash
/git:create-branch "タスク説明"       # git-flow ブランチ作成
/git:commit                           # Conventional Commit（自動検出）
```

## ライセンス

MIT
