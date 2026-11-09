# jiikko/slack-cli の formula（正本はここだけ。ツール側のリポジトリに写しは置かない）。
#
# 🚨 名前が chrome-slack-cli なのは、slack-cli が Homebrew 公式 cask
# （Slack 社の Slack CLI）と衝突するため。インストールされるコマンド名は slack。
#
# sha256 の求め方:
#   curl -sL https://github.com/jiikko/slack-cli/archive/refs/tags/vX.Y.Z.tar.gz | shasum -a 256
class ChromeSlackCli < Formula
  desc "Read-only CLI for Slack that borrows your Chrome login session"
  homepage "https://github.com/jiikko/slack-cli"
  url "https://github.com/jiikko/slack-cli/archive/refs/tags/v0.2.2.tar.gz"
  sha256 "605aac492d80350cf6af54b6cb312c8f5bbe5bd898d16cd9decd31c3a2738e50"
  license "MIT"
  head "https://github.com/jiikko/slack-cli.git", branch: "main"

  depends_on "go" => :build
  depends_on :macos

  def install
    # 🚨 output: を明示する。std_go_args の既定は**バイナリ名 = formula 名**なので、
    # 省くと chrome-slack-cli という名前で入り、README の `slack` コマンドが存在しなくなる。
    system "go", "build", *std_go_args(ldflags: "-s -w", output: bin/"slack"), "./cmd/slack"
  end

  test do
    assert_match "slack - ", shell_output("#{bin}/slack --help")
    # 引数不足は終了コード 2（使い方エラー）
    output = shell_output("#{bin}/slack history 2>&1", 2)
    assert_match "チャンネルを指定してください", output
  end
end
