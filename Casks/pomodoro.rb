cask "pomodoro" do
  version "0.2.3"
  sha256 "7e6221e4219c3d3c43d1db3af91dbdfab8c8481d2230b1e48ecaa6bb871998ef"

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
