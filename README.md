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

### 特定バージョンをインストール
```bash
# インストール（privateリポジトリからDMGを自動でダウンロード）
brew install --cask video-toolkit

# 実行（以下のいずれか）
open -a "Video Toolkit"
# または Launchpad/Applications フォルダから起動
```

### 常に最新版をインストール
```bash
# 最新リリースを自動的に取得してインストール
brew install --cask video-toolkit-latest

# 最新版に更新（reinstallが必要）
brew reinstall --cask video-toolkit-latest
```

## アップデート

```bash
# 特定バージョンの場合
brew update && brew upgrade --cask video-toolkit

# 最新版の場合（reinstallが必要）
brew reinstall --cask video-toolkit-latest
```

## アンインストール

```bash
brew uninstall --cask video-toolkit
```

## 必要な環境

- macOS (Intel または Apple Silicon)
- GitHub CLI (`gh`) - privateリポジトリへのアクセス権限付きで認証済み
- FFmpeg - 自動でインストールされます

## 仕組み

1. Cask が `gh` CLI を使って private GitHub releases からDMGファイルをダウンロード
2. APIトークンや環境変数の設定は不要
3. tap リポジトリは public でOK（Caskのみで、実際のアプリは含まない）
4. video-toolkit リポジトリは private のまま
5. DMGからアプリケーションを自動的に Applications フォルダにインストール

## 開発者向け

### リリース手順

1. video-toolkit リポジトリでDMGをビルド＆リリース:
```bash
cd /Users/koji/src/working/video-toolkit

# バージョンを指定してDMGをビルド
./build-dmg.sh 1.0.1

# GitHub Release を作成（DMGファイルをアップロード）
gh release create v1.0.1 \
  build/release/video-toolkit-1.0.1.dmg \
  --repo jiikko/video-toolkit \
  --title "Release v1.0.1" \
  --notes "Video Toolkit v1.0.1"
```

2. Cask のバージョンを更新:
```bash
cd /Users/koji/src/working/homebrew-tap

# Casks/video-toolkit.rb の version を編集
# version "1.0.0" → version "1.0.1"

git add .
git commit -m "Update video-toolkit to v1.0.1"
git push
```

3. ユーザーは以下でアップデート可能:
```bash
brew update && brew upgrade --cask video-toolkit
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