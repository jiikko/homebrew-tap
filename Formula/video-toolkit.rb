class VideoToolkit < Formula
  desc "Video processing toolkit with web interface"
  homepage "https://github.com/jiikko/video-toolkit"
  version "1.0.0"
  license "MIT"

  # Dummy URL for Homebrew compatibility (actual download uses gh CLI)
  url "https://github.com/jiikko/video-toolkit/archive/refs/tags/v#{version}.tar.gz"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"

  depends_on "gh"
  depends_on "ffmpeg"

  def install
    # Check gh authentication
    unless system("gh", "auth", "status", out: File::NULL, err: File::NULL)
      odie <<~EOS
        GitHub CLI is not authenticated!

        Please run:
          gh auth login

        Then retry the installation:
          brew install jiikko/tap/video-toolkit
      EOS
    end

    # ARM64 only
    binary_name = "video-toolkit-darwin-arm64"

    # Download the pre-built binary from private repo
    ohai "Downloading #{binary_name} from private repository..."

    system "gh", "release", "download", "v#{version}",
           "--repo", "jiikko/video-toolkit",
           "--pattern", "#{binary_name}",
           "--dir", buildpath

    # Make binary executable and install
    chmod 0755, "#{buildpath}/#{binary_name}"
    bin.install "#{binary_name}" => "video-toolkit"
  end

  def post_install
    ohai "Checking FFmpeg installation..."
    unless which("ffmpeg")
      opoo "FFmpeg is not installed. Video processing features will be limited."
      opoo "Install it with: brew install ffmpeg"
    end
  end

  def caveats
    <<~EOS
      Video Toolkit has been installed!

      Usage:
        video-toolkit        # Start the application
        video-toolkit --help # Show help

      The app will open in your default browser at http://localhost:8080

      Requirements:
      ✓ GitHub CLI (authenticated)
      ✓ FFmpeg (for video processing)
    EOS
  end

  test do
    assert_match "video-toolkit", shell_output("#{bin}/video-toolkit --version 2>&1", 0)
  end
end
