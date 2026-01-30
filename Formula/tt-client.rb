class TtClient < Formula
  desc "ThumbnailThumb API client - Command-line interface for ThumbnailThumb app"
  homepage "https://github.com/jiikko/ThumbnailThumb"
  url "https://github.com/jiikko/ThumbnailThumb.git",
      branch: "master"
  version "0.1.0"
  head "https://github.com/jiikko/ThumbnailThumb.git", branch: "develop"

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
