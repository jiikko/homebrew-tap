class TtClient < Formula
  desc "ThumbnailThumb API client - Command-line interface for ThumbnailThumb app"
  homepage "https://github.com/jiikko/homebrew-tap"
  url "https://github.com/jiikko/homebrew-tap/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "a8b4d8dd655c5273b9dbe1d3db1df3cddceb8dec0a9319d5aa2ff4d1e63b0768"
  version "0.1.0"
  license "MIT"

  def install
    bin.install "bin/tt-client"
  end

  test do
    # Test that the script can show help
    output = shell_output("#{bin}/tt-client --help 2>&1", 1)
    assert_match(/ThumbnailThumb API client/, output)
  end

  def caveats
    <<~EOS
      tt-client requires ThumbnailThumb app to be running.

      Usage:
        tt-client /help

      For more information, see:
        https://github.com/jiikko/ThumbnailThumb
    EOS
  end
end
