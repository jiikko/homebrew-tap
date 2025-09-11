class VideoToolkitLatest < Formula
  desc "Video processing toolkit with web interface (Always Latest)"
  homepage "https://github.com/jiikko/video-toolkit"

  # Dummy URL for Homebrew
  url "https://github.com/jiikko/video-toolkit/archive/refs/tags/latest.tar.gz"
  version "latest"

  depends_on "gh"
  depends_on "ffmpeg"

  def install
    # Check gh authentication
    unless system("gh", "auth", "status", out: File::NULL, err: File::NULL)
      odie "GitHub CLI not authenticated! Run: gh auth login"
    end

    # Get latest version dynamically
    latest_version = `gh release list --repo jiikko/video-toolkit --limit 1 | cut -f1`.strip.gsub(/^v/, "")

    if latest_version.empty?
      odie "Could not find any releases"
    end

    ohai "Installing latest version: #{latest_version}"

    # Download latest DMG
    system "gh", "release", "download", "v#{latest_version}",
           "--repo", "jiikko/video-toolkit",
           "--pattern", "video-toolkit-#{latest_version}.dmg",
           "--dir", buildpath

    # Install from DMG
    mount_point = "/Volumes/VideoToolkit"
    system "hdiutil", "attach", "#{buildpath}/video-toolkit-#{latest_version}.dmg",
           "-nobrowse", "-quiet", "-mountpoint", mount_point

    begin
      prefix.install Dir["#{mount_point}/*.app"]
      bin.write_exec_script "#{prefix}/Video Toolkit.app/Contents/MacOS/video-toolkit"
    ensure
      system "hdiutil", "detach", mount_point, "-quiet"
    end
  end

  def caveats
    <<~EOS
      Video Toolkit (Latest) has been installed!
      Run: video-toolkit
    EOS
  end
end
