class Esa < Formula
  desc "Read-only CLI for esa.io that borrows your Chrome login session"
  homepage "https://github.com/jiikko/esa-cli"
  url "https://github.com/jiikko/esa-cli/archive/refs/tags/v0.1.8.tar.gz"
  sha256 "67509a1b1d61b56eed3e70c2b5175a53ea50bc3780405e8c8ab26e97c95ccb69"
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
