cask "pomodoro" do
  version "0.1.0"
  sha256 "1947058ffc53aff567c58dc948d62745f0ee587c416741b2b0557898aac1341d"

  url "https://github.com/craftowen/pomodoro/releases/download/v#{version}/Pomodoro.app.zip"
  name "Pomodoro"
  desc "Lightweight macOS menu bar Pomodoro timer"
  homepage "https://github.com/craftowen/pomodoro"

  depends_on macos: ">= :sonoma"
  auto_updates true

  app "Pomodoro.app"

  zap trash: [
    "~/Library/Preferences/com.pomodoro.app.plist",
    "~/Library/Application Support/Pomodoro",
  ]
end
