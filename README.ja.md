# CC Marketplace for Claude Code

[English version](README.md)

本リポジトリは Claude Code のマーケットプレイスバンドル（cc-marketplace）を提供します。

同梱プラグイン：
- `gh`: 変更を分析し、適切に構造化されたPRを自動生成するプラグイン
- `statusline`: ブランチ・モデル・コスト・所要時間・差分行数・名言を表示するシェル用ステータスラインをインストール

## 機能

### gh プラグイン
- **インテリジェント分析**: gitの変更、コミット、差分を自動的に分析
- **スマートなPR生成**: 適切なフォーマットで包括的なPR説明を作成
- **柔軟なオプション**: ドラフトPR、カスタムベースブランチ、レビュアー指定をサポート
- **エラーハンドリング**: 明確なエラーメッセージと実行可能な解決策を提供
- **GitHub統合**: GitHub CLI (`gh`) とシームレスに統合

### statusline プラグイン
- **豊富なセッション情報**: ブランチ、モデル、コスト、所要時間、変更行数を表示
- **リアルタイム更新**: Claude Code セッション中にリアルタイムで更新
- **名言表示**: 5分ごとに新しいプログラミング名言を表示（キャッシュ機能付き）
- **カラー表示**: 絵文字とカラーコードで視覚的に見やすく表示
- **オフライン対応**: オフライン時も適切にフォールバック

## 必要要件

### gh プラグイン用
- [Claude Code](https://claude.ai/download) がインストールされ実行中
- `git` がインストールされ `PATH` から実行可能
- [GitHub CLI (`gh`)](https://cli.github.com/) がインストールされ認証済み
- PRを作成する変更があるgitリポジトリ

### statusline プラグイン用
- [Claude Code](https://claude.ai/download) がインストールされ実行中
- `jq` がインストールされ `PATH` から実行可能（JSON解析用）
- `curl` がインストール済み（名言取得用、オプション）
- gitリポジトリ（ブランチ表示用、オプション）

## インストール

### GitHubから（推奨）

```bash
/plugin marketplace add setouchi-h/cc-marketplace
# gh プラグインのインストール
/plugin install gh@cc-marketplace
# statusline プラグインのインストール
/plugin install statusline@cc-marketplace
```

### ローカルディレクトリから

```bash
cd /path/to/cc-marketplace
/plugin install .
```

---

## gh プラグイン

### 使い方

### 基本的な使い方

Claude Codeでコマンドを実行するだけです：

```bash
/gh:create-pr
```

プラグインは以下を実行します：
1. 現在のブランチと変更を分析
2. 包括的なPRタイトルと説明を生成
3. 必要に応じてブランチをプッシュ
4. GitHubでプルリクエストを作成
5. PR URLを表示

### 高度なオプション

```bash
# ドラフトPRを作成
/create-pr --draft

# 異なるベースブランチを指定
/create-pr --base develop

# レビュアーを追加
/create-pr --reviewer username1 --reviewer username2

# 自動プッシュをスキップ（ブランチが既にプッシュ済みの場合）
/create-pr --no-push

# 可能であれば自分にアサイン
/create-pr --assign-me
```

### フラグ

- `-d, --draft`: ドラフトPRとして作成
- `-b, --base <branch>`: 既定のベースブランチの代わりに使用（既定はリポジトリのデフォルトブランチ。一般的に `main` または `master`）
- `-r, --reviewer <user>`: 指定したGitHubユーザーをレビュアーに追加。複数追加する場合はフラグを繰り返し指定
- `--no-push`: PR作成前のブランチのプッシュをスキップ
- `--assign-me`: 認証ユーザー（`@me`）をアサインしようと試みます。アサインはPR作成後に実行され、権限がない場合は警告のみ表示し、PR作成自体は成功のままにします。

短縮形を使った例：

```bash
# カスタムベースのドラフトPR。レビュアーを2名追加
/create-pr -d -b develop -r alice -r bob
```

### 動作の仕組み

1. **ブランチ分析**: 現在のブランチステータスとリモートトラッキングを確認
2. **変更検出**: ベースブランチからのコミットと差分を分析
3. **コンテンツ生成**: 以下を含むPRを作成：
   - 簡潔で説明的なタイトル（命令形、72文字未満）
   - 包括的な説明：
     - 変更の概要
     - 詳細な変更リスト
     - 動機と文脈
     - テスト情報
     - 追加の注記
4. **PR作成**: `gh pr create` を使用してプルリクエストを作成
5. **結果表示**: PR URLと概要を表示

### 権限

このプラグインは以下のローカルコマンドを呼び出します：

- `git` — ステータス、ブランチ、コミット、差分の取得のため
- `gh` — GitHub CLI を用いたプルリクエスト作成のため

既存の `gh auth login` セッションに依存し、認証情報をプラグイン側で保存しません。

### PR説明の例

プラグインは以下の構造でPRを生成します：

```markdown
## Summary
このPRが達成する内容の簡単な概要

## Changes
- 主な変更や機能1
- 主な変更や機能2
- 主な変更や機能3

## Motivation
これらの変更が必要な理由の説明

## Testing
- 変更がどのようにテストされたか
- テスト結果または検証手順

## Notes
追加の文脈、破壊的変更、またはレビュアーへの注記
```

### トラブルシューティング

#### コマンドが見つからない

`/create-pr` コマンドが認識されない場合：
1. プラグインがインストールされているか確認: `/plugin list`
2. 必要に応じて再インストール: `/plugin install gh@cc-marketplace`
3. Claude Codeを再起動

#### GitHub CLIが見つからない

GitHub CLIをインストール：
- macOS: `brew install gh`
- Linux: [GitHub CLIインストール](https://github.com/cli/cli#installation)を参照
- Windows: `winget install --id GitHub.cli`

その後認証: `gh auth login`

#### ブランチがプッシュされていない

プラグインは自動的にブランチをプッシュします。失敗した場合：
1. gitリモート設定を確認
2. リポジトリへのプッシュアクセスがあることを確認
3. マージコンフリクトを解決
4. 手動でプッシュを試行: `git push -u origin <branch-name>`

---

## statusline プラグイン

### 概要

statusline プラグインは、Claude Code セッションに関する豊富な情報を表示するカスタマイズ可能なステータスラインスクリプトをインストールします。現在の git ブランチ、AI モデル、セッションコスト、所要時間、変更行数、プログラミング名言などを表示します。

### 表示内容

ステータスラインには以下の情報が表示されます：
- 🌿 **現在のブランチ**: Git ブランチ名（例：`main`、`feature/new-ui`）
- 🤖 **モデル**: AI モデル名と ID（例：`Sonnet 4.5`）
- 💰 **コスト**: セッション全体のコスト（USD）（例：`$0.0123`）
- ⏱️ **所要時間**: セッションの経過時間（分/秒）（例：`1m49s`）
- 📝 **変更**: 追加/削除された行数（例：`+10/-2`）
- 💬 **名言**: ランダムなプログラミング名言（5分ごとに更新）

出力例：
```
🌿 main | 🤖 Sonnet 4.5 (claude-sonnet-4-5-20250929) | 💰 $0.0123 | ⏱️ 1m49s | 📝 +10/-2 | 💬 "Code is poetry" - Anonymous
```

### インストール

#### ステップ1: プラグインのインストール

```bash
/plugin marketplace add setouchi-h/cc-marketplace
/plugin install statusline@cc-marketplace
```

#### ステップ2: インストールコマンドの実行

```bash
/statusline:install-statusline
```

このコマンドは以下を実行します：
- `jq` がインストールされているか確認（JSON解析に必要）
- `~/.claude/scripts/` ディレクトリが存在しない場合は作成
- `~/.claude/scripts/statusline.sh` にステータスラインスクリプトを書き込み
- スクリプトを実行可能にする

#### ステップ3: Claude Code の設定

`~/.config/claude/config.json` を編集して、ステータスラインを Claude Code の設定に追加します：

```json
{
  "statusline": {
    "command": "~/.claude/scripts/statusline.sh"
  }
}
```

または、Claude Code の設定 UI を使用してステータスラインコマンドのパスを設定します。

### 使い方

#### インストールまたは更新

```bash
# 初回インストール
/statusline:install-statusline

# 強制的に再インストール（既存のスクリプトを上書き）
/statusline:install-statusline --force
```

#### ステータスラインのプレビュー

フルセッションを開始せずにステータスラインをテストします：

```bash
/statusline:preview-statusline
```

これにより、モックデータを使用してサンプルのステータスラインがレンダリングされ、色とレイアウトを確認できます。

### 動作の仕組み

1. **JSON入力**: Claude Code がセッションデータを JSON として標準入力経由でスクリプトに渡します
2. **データ抽出**: スクリプトは `jq` を使用して以下を解析します：
   - セッションのコストと所要時間
   - 追加/削除された行数
   - モデル名と ID
   - ワークスペースディレクトリ
3. **Git ブランチ**: ワークスペースから現在の git ブランチを検出
4. **名言の取得**:
   - [ZenQuotes API](https://zenquotes.io/) からランダムな名言を取得
   - API 呼び出しを減らすため、名言を5分間キャッシュ
   - オフライン時はキャッシュまたはデフォルトの名言にフォールバック
5. **フォーマット**: 絵文字と ANSI カラーコードを使用して1行を出力

### 必要要件

- **jq**: JSON 解析に必須
  - macOS: `brew install jq`
  - Linux: `sudo apt-get install jq` または `sudo yum install jq`
  - Windows: [jqlang.github.io](https://jqlang.github.io/jq/download/) からダウンロード
- **curl**: 名言の取得に使用（オプション、利用できない場合は適切に動作を低下）
- **git**: ブランチ名の表示に使用（オプション）

### トラブルシューティング

#### jq が見つからない

「jq is required but not installed」というエラーが表示される場合：

1. jq をインストール：
   - macOS: `brew install jq`
   - Ubuntu/Debian: `sudo apt-get install jq`
   - Fedora/RHEL: `sudo yum install jq`
2. インストールを確認: `which jq`
3. Claude Code を再起動

#### スクリプトが実行されない

ステータスラインが表示されない場合：

1. スクリプトが存在することを確認: `ls -l ~/.claude/scripts/statusline.sh`
2. 実行可能であることを確認: `chmod +x ~/.claude/scripts/statusline.sh`
3. 手動でテスト: `/statusline:preview-statusline`
4. Claude Code の設定が正しいパスを指していることを確認
5. Claude Code を再起動

#### 名言が表示されない

名言が表示されない場合：

1. インターネット接続を確認（名言は zenquotes.io から取得されます）
2. スクリプトは名言を5分間キャッシュし、オフライン時はデフォルト値にフォールバックします
3. curl をテスト: `curl -s "https://zenquotes.io/api/random"`
4. curl がインストールされていない場合、名言はフォールバック値を使用します

#### 色が表示されない

色が正しく表示されない場合：

1. ターミナルが ANSI カラーをサポートしていることを確認
2. ターミナルの色設定を確認
3. 一部のターミナルでは256色サポートが必要な場合があります

### カスタマイズ

ステータスラインをカスタマイズするには、`~/.claude/scripts/statusline.sh` を編集します：

- 末尾の `printf` フォーマット文字列を変更してレイアウトを変更
- カラーコードを調整（例：`\033[1;92m` は明るい緑）
- 絵文字を変更または削除
- 名言のソースを変更または名言取得を無効化

編集後、`/statusline:preview-statusline` でテストしてください。

## 貢献

貢献を歓迎します！IssueやPull Requestをお気軽に送信してください。

1. リポジトリをフォーク
2. フィーチャーブランチを作成
3. 変更をコミット
4. ブランチにプッシュ
5. Pull Requestを作成

## ライセンス

MIT License - 詳細は [LICENSE](LICENSE) ファイルを参照してください
