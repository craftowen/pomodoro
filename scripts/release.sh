#!/bin/bash
set -e

echo "Building release..."
swift build -c release 2>&1

APP_DIR=".build/release/Pomodoro.app/Contents"
mkdir -p "$APP_DIR/MacOS"

cp .build/release/Pomodoro "$APP_DIR/MacOS/Pomodoro"
cp Pomodoro/Info.plist "$APP_DIR/Info.plist"

# Add bundle identifier and other required entries to Info.plist
/usr/libexec/PlistBuddy -c "Delete :CFBundleIdentifier" "$APP_DIR/Info.plist" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string com.pomodoro.app" "$APP_DIR/Info.plist"
/usr/libexec/PlistBuddy -c "Delete :CFBundleName" "$APP_DIR/Info.plist" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :CFBundleName string Pomodoro" "$APP_DIR/Info.plist"
/usr/libexec/PlistBuddy -c "Delete :CFBundlePackageType" "$APP_DIR/Info.plist" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :CFBundlePackageType string APPL" "$APP_DIR/Info.plist"
/usr/libexec/PlistBuddy -c "Delete :NSPrincipalClass" "$APP_DIR/Info.plist" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :NSPrincipalClass string NSApplication" "$APP_DIR/Info.plist"

# Create zip for distribution
echo "Creating Pomodoro.app.zip..."
cd .build/release
rm -f Pomodoro.app.zip
zip -r Pomodoro.app.zip Pomodoro.app

# Calculate SHA256 hash
echo ""
echo "========================================"
echo "Release build complete!"
echo "========================================"
echo ""
echo "Zip file: $(pwd)/Pomodoro.app.zip"
echo ""
echo "SHA256:"
shasum -a 256 Pomodoro.app.zip
echo ""
