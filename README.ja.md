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

![Statusline Example](assets/statusline.png)

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

インテリジェントな分析によるプルリクエスト作成。

```bash
/gh:create-pr                         # 現在のブランチから PR 作成
/gh:create-pr -d -b develop          # develop に対するドラフト PR
/gh:create-pr -r alice -r bob        # レビュアーを追加
```

**フラグ:**
- `-d, --draft`: ドラフト PR として作成
- `-b, --base <branch>`: ベースブランチを指定（デフォルト: リポジトリのデフォルト）
- `-r, --reviewer <user>`: レビュアーを追加（複数指定可能）
- `--no-push`: ブランチのプッシュをスキップ
- `--no-assign`: 自分へのアサインをスキップ

### git

Git-flow ワークフロー自動化（ブランチ作成と Conventional Commit）。

```bash
/git:create-branch "タスク説明"       # git-flow ブランチ作成
/git:create-branch "バグ修正" --type bugfix --base main
/git:commit                           # Conventional Commit（自動検出）
/git:commit --type feat --scope auth --no-push
```

**create-branch フラグ:**
- `--base <branch>`: ベースブランチを指定（デフォルト: 自動検出）
- `--type <type>`: ブランチタイプを強制（feature/bugfix/hotfix/release）
- `--no-push`: リモートへプッシュしない

**commit フラグ:**
- `--type <type>`: コミットタイプを強制（feat/fix/docs など）
- `--scope <scope>`: コミットスコープを指定
- `--no-push`: リモートへプッシュしない

## ライセンス

MIT
