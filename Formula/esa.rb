class Esa < Formula
  desc "Read-only CLI for esa.io that borrows your Chrome login session"
  homepage "https://github.com/jiikko/esa-cli"
  url "https://github.com/jiikko/esa-cli/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "8953b7899593ebad8f0ba6bbdcd8171366cad8a7ad62a0a0e9cd17f2a024c7c7"
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
