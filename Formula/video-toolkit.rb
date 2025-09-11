class VideoToolkit < Formula
  desc "Video processing toolkit with web interface"
  homepage "https://github.com/jiikko/video-toolkit"
  version "20250911204035"
  license "MIT"

  # Dummy URL for Homebrew compatibility (actual download uses gh CLI)
  url "https://github.com/jiikko/video-toolkit/archive/refs/tags/v#{version}.tar.gz"
  # sha256 "0000000000000000000000000000000000000000000000000000000000000000"

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

    # DMG file name
    dmg_name = "video-toolkit-#{version}.dmg"

    # Download the DMG from private repo
    ohai "Downloading #{dmg_name} from private repository..."

    system "gh", "release", "download", "v#{version}",
           "--repo", "jiikko/video-toolkit",
           "--pattern", "#{dmg_name}",
           "--dir", buildpath

    # Mount the DMG
    ohai "Mounting #{dmg_name}..."
    mount_point = "/Volumes/VideoToolkit"
    system "hdiutil", "attach", "#{buildpath}/#{dmg_name}", "-nobrowse", "-quiet", "-mountpoint", mount_point

    begin
      # Copy the app to Applications (or extract binary if it's not an .app bundle)
      app_path = "#{mount_point}/Video Toolkit.app"
      if File.exist?(app_path)
        # If it's an .app bundle, copy to prefix
        prefix.install Dir["#{mount_point}/*.app"]
        # Create a command-line wrapper
        bin.write_exec_script "#{prefix}/Video Toolkit.app/Contents/MacOS/video-toolkit"
      else
        # If it's just a binary in the DMG
        bin.install "#{mount_point}/video-toolkit"
      end
    ensure
      # Always unmount the DMG
      system "hdiutil", "detach", mount_point, "-quiet"
    end
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
