# CC Marketplace for Claude Code

[English version](README.md)

Claude Code マーケットプレイスバンドル（開発必須プラグイン集）

## プラグイン

- **statusline**: ブランチ・モデル・コスト・所要時間・変更を表示するステータスライン
- **gh**: インテリジェントな PR 自動作成
- **git**: Git-flow ワークフロー自動化（ブランチ作成、Conventional Commit）
- **xcode**: Xcode プロジェクトをシミュレータまたは実機でビルド・実行
- **fxembed**: X (Twitter) のツイート・プロフィールを FxEmbed JSON API 経由で取得

## インストール

```bash
/plugin marketplace add setouchi-h/cc-marketplace
/plugin install statusline@cc-marketplace
/plugin install gh@cc-marketplace
/plugin install git@cc-marketplace
/plugin install xcode@cc-marketplace
/plugin install fxembed@cc-marketplace
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

### xcode

Xcode プロジェクトを iOS シミュレータまたは実機でビルド・実行。

```bash
/xcode:run                                           # 自動検出して実行
/xcode:run --simulator "iPhone 15 Pro"               # 特定のシミュレータ
/xcode:run --scheme MyApp --simulator "iPad Pro"     # スキーム + シミュレータ
/xcode:run --device "My iPhone"                      # 実機
/xcode:run --clean --configuration Release           # クリーン Release ビルド
```

**フラグ:**
- `--scheme <name>`: ビルドスキームを指定（複数ある場合は必須）
- `--simulator <name>`: シミュレータで実行（例: "iPhone 15 Pro"）
- `--device <name>`: 接続された実機で実行
- `--clean`: クリーンビルドを実行
- `--configuration <config>`: ビルド構成（Debug/Release、デフォルト: Debug）

**必要要件:**
- Xcode とコマンドラインツールがインストールされていること
- 実機の場合、適切なコード署名設定が必要

### fxembed

Claude が X (Twitter) の内容を読めるようにします。X は未認証アクセスをブロックする
ため `x.com` リンクの直接取得は失敗します。このスキルはツイート URL を
[FxEmbed](https://github.com/FxEmbed/FxEmbed) の JSON API（`api.fxtwitter.com`）に
書き換えて curl で取得する方法を Claude に教えます。スラッシュコマンドは不要で、
インストール後はツイート URL が会話に出てくると自動的に発動します。

```
https://x.com/user/status/123  →  https://api.fxtwitter.com/2/status/123
```

**できること:**
- ツイート本文・投稿者・メトリクス・メディアリンク・引用・アンケートを JSON で取得
- ユーザープロフィール取得（`/2/profile/{screen_name}`）
- 検索（`/2/search`）とユーザータイムライン（`/2/profile/{screen_name}/statuses`）
- `d.fxtwitter.com` 経由のメディア直ダウンロード
- 取得コンテンツを信頼しないデータとして扱う（プロンプトインジェクション対策の指針）
- FxEmbed ダウン時の vxTwitter フォールバック

**制限:**
- 公開コンテンツのみ（鍵アカウントは 401、削除済みは 404）

## ライセンス

MIT
