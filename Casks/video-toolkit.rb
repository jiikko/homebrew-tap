cask "video-toolkit" do
  version "20250911204035"
  sha256 :no_check

  url do
    require "open3"

    # Check gh authentication
    stdout, stderr, status = Open3.capture3("gh", "auth", "status")
    unless status.success?
      raise CaskError, <<~EOS
        GitHub CLI is not authenticated!

        Please run:
          gh auth login

        Then retry the installation:
          brew install --cask jiikko/tap/video-toolkit
      EOS
    end

    # Download URL from private repo using gh CLI
    dmg_name = "video-toolkit-#{version}.dmg"
    temp_dir = Dir.mktmpdir

    system_command "gh",
                   args: ["release", "download", "v#{version}",
                          "--repo", "jiikko/video-toolkit",
                          "--pattern", dmg_name,
                          "--dir", temp_dir]

    "file://#{temp_dir}/#{dmg_name}"
  end

  name "Video Toolkit"
  desc "Video processing toolkit with web interface"
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
    Video Toolkit has been installed!

    You can launch it from Applications or from the command line:
      open -a "Video Toolkit"

    Requirements:
    ✓ GitHub CLI (authenticated)
    ✓ FFmpeg (for video processing)

    The app will open in your default browser at http://localhost:8080
  EOS
end
