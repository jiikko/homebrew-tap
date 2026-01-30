class TtClient < Formula
  desc "ThumbnailThumb API client - Command-line interface for ThumbnailThumb app"
  homepage "https://github.com/jiikko/homebrew-tap"
  head "https://github.com/jiikko/homebrew-tap.git", branch: "master"

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
