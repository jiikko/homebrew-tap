cask "video-toolkit-latest" do
  version :latest
  sha256 :no_check

  url do
    require "open3"
    require "json"

    # Check gh authentication
    stdout, stderr, status = Open3.capture3("gh", "auth", "status")
    unless status.success?
      raise CaskError, <<~EOS
        GitHub CLI is not authenticated!

        Please run:
          gh auth login

        Then retry the installation:
          brew install --cask jiikko/tap/video-toolkit-latest
      EOS
    end

    # Get latest release info
    stdout, stderr, status = Open3.capture3(
      "gh", "api", "repos/jiikko/video-toolkit/releases/latest",
      "--jq", ".tag_name"
    )

    unless status.success?
      raise CaskError, "Failed to get latest release: #{stderr}"
    end

    latest_version = stdout.strip.gsub(/^v/, "")

    # Download DMG from latest release
    dmg_name = "video-toolkit-#{latest_version}.dmg"
    temp_dir = Dir.mktmpdir

    system_command "gh",
                   args: ["release", "download", "latest",
                          "--repo", "jiikko/video-toolkit",
                          "--pattern", dmg_name,
                          "--dir", temp_dir]

    "file://#{temp_dir}/#{dmg_name}"
  end

  name "Video Toolkit (Latest)"
  desc "Video processing toolkit with web interface (always latest version)"
  homepage "https://github.com/jiikko/video-toolkit"

  depends_on formula: "gh"
  depends_on formula: "ffmpeg"

  app "Video Toolkit.app"

  zap trash: [
    "~/Library/Application Support/VideoToolkit",
    "~/Library/Preferences/com.jiikko.video-toolkit.plist",
    "~/Library/Caches/com.jiikko.video-toolkit",
  ]

  caveats <<~EOS
    Video Toolkit (Latest) has been installed!

    This cask always installs the latest release version.
    To update to the newest release, run:
      brew reinstall --cask video-toolkit-latest

    You can launch it from Applications or from the command line:
      open -a "Video Toolkit"

    Requirements:
    ✓ GitHub CLI (authenticated)
    ✓ FFmpeg (for video processing)

    The app will open in your default browser at http://localhost:8080
  EOS
end
