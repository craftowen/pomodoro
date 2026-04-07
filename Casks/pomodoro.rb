cask "pomodoro" do
  version "0.2.1"
  sha256 "dab83e9539f42f629257d95ec4f317d25c433d53e5d9677e78b405373e9ca081"

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
