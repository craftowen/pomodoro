#!/bin/bash
set -e

VERSION="${1:?Usage: update-appcast.sh <version> <signature> <length>}"
SIGNATURE="${2:?Usage: update-appcast.sh <version> <signature> <length>}"
LENGTH="${3:?Usage: update-appcast.sh <version> <signature> <length>}"

APPCAST_FILE="appcast.xml"
PUB_DATE=$(date -u +"%a, %d %b %Y %H:%M:%S %z")
DOWNLOAD_URL="https://github.com/craftowen/pomodoro/releases/download/v${VERSION}/Pomodoro.app.zip"

NEW_ITEM="        <item>\n            <title>Version ${VERSION}<\/title>\n            <pubDate>${PUB_DATE}<\/pubDate>\n            <sparkle:version>${VERSION}<\/sparkle:version>\n            <sparkle:shortVersionString>${VERSION}<\/sparkle:shortVersionString>\n            <enclosure url=\"${DOWNLOAD_URL}\"\n                       sparkle:edSignature=\"${SIGNATURE}\"\n                       length=\"${LENGTH}\"\n                       type=\"application\/octet-stream\"\/>\n        <\/item>"

# Insert new item before </channel>
sed -i '' "s|    </channel>|${NEW_ITEM}\n    </channel>|" "$APPCAST_FILE"

echo "Updated ${APPCAST_FILE} with version ${VERSION}"
