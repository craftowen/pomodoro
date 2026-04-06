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

  app "Pomodoro.app"

  zap trash: [
    "~/Library/Preferences/com.pomodoro.app.plist",
    "~/Library/Application Support/Pomodoro",
  ]
end
EOF

echo "Updated ${CASK_FILE} to version ${VERSION}"
