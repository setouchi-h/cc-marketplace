# PR Creator Plugin for Claude Code

[日本語版はこちら](#日本語)

An intelligent Claude Code plugin that analyzes your changes and creates well-structured pull requests automatically.

## Features

- **Intelligent Analysis**: Automatically analyzes your git changes, commits, and diffs
- **Smart PR Generation**: Creates comprehensive PR descriptions with proper formatting
- **Flexible Options**: Supports draft PRs, custom base branches, and reviewer assignments
- **Error Handling**: Provides clear error messages and actionable solutions
- **GitHub Integration**: Seamlessly integrates with GitHub CLI (`gh`)

## Prerequisites

- [Claude Code](https://claude.ai/download) installed and running
- [GitHub CLI (`gh`)](https://cli.github.com/) installed and authenticated
- A git repository with changes to create a PR from

## Installation

### From GitHub (Recommended)

```bash
/plugin marketplace add setouchi-h/pr-tools
/plugin install pr-creator@pr-tools
```

### From Local Directory

```bash
cd /path/to/pr-tools
/plugin install .
```

## Usage

### Basic Usage

Simply run the command in Claude Code:

```bash
/create-pr
```

The plugin will:
1. Analyze your current branch and changes
2. Generate a comprehensive PR title and description
3. Push your branch if needed
4. Create the pull request on GitHub
5. Display the PR URL

### Advanced Options

```bash
# Create a draft PR
/create-pr --draft

# Specify a different base branch
/create-pr --base develop

# Add reviewers
/create-pr --reviewer username1 --reviewer username2

# Skip automatic push (if branch is already pushed)
/create-pr --no-push
```

## How It Works

1. **Branch Analysis**: Checks your current branch status and remote tracking
2. **Change Detection**: Analyzes commits and diffs since the base branch
3. **Content Generation**: Creates a PR with:
   - Concise, descriptive title (imperative mood, <72 chars)
   - Comprehensive description including:
     - Summary of changes
     - Detailed change list
     - Motivation and context
     - Testing information
     - Additional notes
4. **PR Creation**: Uses `gh pr create` to create the pull request
5. **Result Display**: Shows the PR URL and summary

## Example PR Description

The plugin generates PRs with this structure:

```markdown
## Summary
Brief overview of what this PR accomplishes

## Changes
- Key change or feature 1
- Key change or feature 2
- Key change or feature 3

## Motivation
Explanation of why these changes were needed

## Testing
- How the changes were tested
- Test results or validation steps

## Notes
Any additional context, breaking changes, or reviewer notes
```

## Troubleshooting

### Command Not Found

If the `/create-pr` command is not recognized:
1. Verify the plugin is installed: `/plugin list`
2. Reinstall if needed: `/plugin install pr-creator@pr-tools`
3. Restart Claude Code

### GitHub CLI Not Found

Install the GitHub CLI:
- macOS: `brew install gh`
- Linux: See [GitHub CLI installation](https://github.com/cli/cli#installation)
- Windows: `winget install --id GitHub.cli`

Then authenticate: `gh auth login`

### Branch Not Pushed

The plugin automatically pushes your branch. If it fails:
1. Check your git remote configuration
2. Verify you have push access to the repository
3. Resolve any merge conflicts
4. Try pushing manually: `git push -u origin <branch-name>`

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

MIT License - see [LICENSE](LICENSE) file for details

---

# 日本語

Claude Code用のインテリジェントなPR作成プラグインです。変更を自動的に分析し、適切に構造化されたプルリクエストを作成します。

## 機能

- **インテリジェント分析**: gitの変更、コミット、差分を自動的に分析
- **スマートなPR生成**: 適切なフォーマットで包括的なPR説明を作成
- **柔軟なオプション**: ドラフトPR、カスタムベースブランチ、レビュアー指定をサポート
- **エラーハンドリング**: 明確なエラーメッセージと実行可能な解決策を提供
- **GitHub統合**: GitHub CLI (`gh`) とシームレスに統合

## 必要要件

- [Claude Code](https://claude.ai/download) がインストールされ実行中
- [GitHub CLI (`gh`)](https://cli.github.com/) がインストールされ認証済み
- PRを作成する変更があるgitリポジトリ

## インストール

### GitHubから（推奨）

```bash
/plugin marketplace add setouchi-h/pr-tools
/plugin install pr-creator@pr-tools
```

### ローカルディレクトリから

```bash
cd /path/to/pr-tools
/plugin install .
```

## 使い方

### 基本的な使い方

Claude Codeでコマンドを実行するだけです：

```bash
/create-pr
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
```

## 動作の仕組み

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

## PR説明の例

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

## トラブルシューティング

### コマンドが見つからない

`/create-pr` コマンドが認識されない場合：
1. プラグインがインストールされているか確認: `/plugin list`
2. 必要に応じて再インストール: `/plugin install pr-creator@pr-tools`
3. Claude Codeを再起動

### GitHub CLIが見つからない

GitHub CLIをインストール：
- macOS: `brew install gh`
- Linux: [GitHub CLIインストール](https://github.com/cli/cli#installation)を参照
- Windows: `winget install --id GitHub.cli`

その後認証: `gh auth login`

### ブランチがプッシュされていない

プラグインは自動的にブランチをプッシュします。失敗した場合：
1. gitリモート設定を確認
2. リポジトリへのプッシュアクセスがあることを確認
3. マージコンフリクトを解決
4. 手動でプッシュを試行: `git push -u origin <branch-name>`

## 貢献

貢献を歓迎します！IssueやPull Requestをお気軽に送信してください。

1. リポジトリをフォーク
2. フィーチャーブランチを作成
3. 変更をコミット
4. ブランチにプッシュ
5. Pull Requestを作成

## ライセンス

MIT License - 詳細は [LICENSE](LICENSE) ファイルを参照してください
