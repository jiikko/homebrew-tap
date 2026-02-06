class TtClient < Formula
  desc "ThumbnailThumb API client - Command-line interface for ThumbnailThumb app"
  homepage "https://github.com/jiikko/homebrew-tap"
  url "https://github.com/jiikko/homebrew-tap/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "1731eaa065f2f01baf3d685d04740332eb464b5695de1a7afb6af298c9e4ed99"
  version "0.3.0"
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
        https://jiikko.com/thumbnail-thumb/
    EOS
  end
end
