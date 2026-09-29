class Esa < Formula
  desc "Read-only CLI for esa.io that borrows your Chrome login session"
  homepage "https://github.com/jiikko/esa-cli"
  url "https://github.com/jiikko/esa-cli/archive/refs/tags/v0.3.1.tar.gz"
  sha256 "f277a636cbbd35b159c67483f72e79591ffd3617b43d4d992117ae54bdad120a"
  license "MIT"
  head "https://github.com/jiikko/esa-cli.git", branch: "main"

  depends_on "go" => :build
  depends_on :macos

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w"), "./cmd/esa"
  end

  test do
    assert_match "esa - ", shell_output("#{bin}/esa --help")
    # 引数不足は終了コード 2（使い方エラー）
    output = shell_output("#{bin}/esa search 2>&1", 2)
    assert_match "検索クエリを指定してください", output
  end
end
