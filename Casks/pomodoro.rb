cask "pomodoro" do
  version "0.2.0"
  sha256 "aeabd0ef4b860019651412a9668ff496c535611afb9a84b71b2bd0d5750e823d"

  url "https://github.com/craftowen/pomodoro/releases/download/v#{version}/Pomodoro.app.zip"
  name "Pomodoro"
  desc "Lightweight macOS menu bar Pomodoro timer"
  homepage "https://github.com/craftowen/pomodoro"

  depends_on macos: ">= :sonoma"
  auto_updates true

  app "Pomodoro.app"

  uninstall quit: "com.pomodoro.app"

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-cr", "#{appdir}/Pomodoro.app"]
  end

  zap trash: [
    "~/Library/Preferences/com.pomodoro.app.plist",
    "~/Library/Application Support/Pomodoro",
  ]
end
