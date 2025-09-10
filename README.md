# Homebrew Tap for jiikko

Personal Homebrew tap for private tools.

## Setup (初回のみ)

```bash
# 1. GitHub CLIで認証（privateリポジトリへのアクセス権限が必要）
gh auth login

# 2. tapを追加
brew tap jiikko/tap
```

## Video Toolkit のインストール

```bash
# インストール（privateリポジトリから自動でダウンロード）
brew install video-toolkit

# 実行
video-toolkit
```

## アップデート

```bash
brew update && brew upgrade video-toolkit
```

## アンインストール

```bash
brew uninstall video-toolkit
```

## 必要な環境

- macOS (Intel または Apple Silicon)
- GitHub CLI (`gh`) - privateリポジトリへのアクセス権限付きで認証済み
- FFmpeg - 自動でインストールされます

## 仕組み

1. Formula が `gh` CLI を使って private GitHub releases からビルド済みバイナリをダウンロード
2. APIトークンや環境変数の設定は不要
3. tap リポジトリは public でOK（Formulaのみで、実際のバイナリは含まない）
4. video-toolkit リポジトリは private のまま

## 開発者向け

### リリース手順

1. video-toolkit リポジトリでビルド＆リリース:
```bash
cd /Users/koji/src/working/video-toolkit

# バージョンを指定してビルド
./release-homebrew.sh 1.0.1

# GitHub Release を作成
gh release create v1.0.1 \
  build/release/video-toolkit-darwin-arm64 \
  build/release/video-toolkit-darwin-amd64 \
  --repo jiikko/video-toolkit \
  --title "Release v1.0.1" \
  --notes "Video Toolkit v1.0.1"
```

2. Formula のバージョンを更新:
```bash
cd /Users/koji/src/working/homebrew-tap

# Formula/video-toolkit.rb の version を編集
# version "1.0.0" → version "1.0.1"

git add .
git commit -m "Update video-toolkit to v1.0.1"
git push
```

3. ユーザーは以下でアップデート可能:
```bash
brew update && brew upgrade video-toolkit
```

### トラブルシューティング

**GitHub CLI の認証エラーが出る場合:**
```bash
gh auth status  # 認証状態を確認
gh auth login   # 再認証
```

**privateリポジトリにアクセスできない場合:**
```bash
# リポジトリへのアクセス権限があるか確認
gh repo view jiikko/video-toolkit
```

**Formula の更新が反映されない場合:**
```bash
brew update
brew untap jiikko/tap
brew tap jiikko/tap
```