cask "pomodoro" do
  version :latest
  sha256 :no_check

  url "https://github.com/craftowen/pomodoro/releases/latest/download/Pomodoro.app.zip"
  name "Pomodoro"
  desc "Lightweight macOS menu bar Pomodoro timer"
  homepage "https://github.com/craftowen/pomodoro"

  app "Pomodoro.app"

  zap trash: [
    "~/Library/Preferences/com.pomodoro.app.plist",
    "~/Library/Application Support/Pomodoro",
  ]
end
