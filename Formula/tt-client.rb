class TtClient < Formula
  desc "ThumbnailThumb API client - Command-line interface for ThumbnailThumb app"
  homepage "https://github.com/jiikko/homebrew-tap"
  url "https://github.com/jiikko/homebrew-tap/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "3914401e3881a05ee25b1bb809ee2ec04336bb102490704943f4d49d0bd28de2"
  version "0.2.0"
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
