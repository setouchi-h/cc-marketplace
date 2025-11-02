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
```bash
/statusline:install-statusline        # ステータスラインのインストール
/statusline:preview-statusline        # プレビュー表示
```

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
