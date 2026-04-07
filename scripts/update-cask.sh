#!/bin/bash
set -e

VERSION="${1:?Usage: update-cask.sh <version> <sha256>}"
SHA256="${2:?Usage: update-cask.sh <version> <sha256>}"

CASK_FILE="Casks/pomodoro.rb"

cat > "$CASK_FILE" << EOF
cask "pomodoro" do
  version "${VERSION}"
  sha256 "${SHA256}"

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
EOF

echo "Updated ${CASK_FILE} to version ${VERSION}"
