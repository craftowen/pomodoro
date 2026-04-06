#!/bin/bash
set -e

echo "Building..."
swift build -c debug 2>&1

APP_DIR=".build/Pomodoro.app/Contents"
mkdir -p "$APP_DIR/MacOS"
mkdir -p "$APP_DIR/Resources"
mkdir -p "$APP_DIR/Frameworks"

cp .build/debug/Pomodoro "$APP_DIR/MacOS/Pomodoro"
cp Pomodoro/Info.plist "$APP_DIR/Info.plist"

# Copy localized strings into app bundle so Bundle.main can find them
BUNDLE_DIR=$(find .build -path "*/debug/Pomodoro_Pomodoro.bundle" -type d 2>/dev/null | head -1)
if [ -n "$BUNDLE_DIR" ]; then
    for lproj in "$BUNDLE_DIR"/*.lproj; do
        cp -R "$lproj" "$APP_DIR/Resources/"
    done
fi

# Add bundle identifier to Info.plist
/usr/libexec/PlistBuddy -c "Delete :CFBundleIdentifier" "$APP_DIR/Info.plist" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string com.pomodoro.app" "$APP_DIR/Info.plist"
/usr/libexec/PlistBuddy -c "Delete :CFBundleName" "$APP_DIR/Info.plist" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :CFBundleName string Pomodoro" "$APP_DIR/Info.plist"
/usr/libexec/PlistBuddy -c "Delete :CFBundlePackageType" "$APP_DIR/Info.plist" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :CFBundlePackageType string APPL" "$APP_DIR/Info.plist"
/usr/libexec/PlistBuddy -c "Delete :NSPrincipalClass" "$APP_DIR/Info.plist" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :NSPrincipalClass string NSApplication" "$APP_DIR/Info.plist"

# Embed Sparkle.framework
SPARKLE_FW=$(find .build/artifacts -name "Sparkle.framework" -path "*/macos*" -type d 2>/dev/null | head -1)
if [ -n "$SPARKLE_FW" ]; then
    cp -R "$SPARKLE_FW" "$APP_DIR/Frameworks/"
    install_name_tool -add_rpath @executable_path/../Frameworks "$APP_DIR/MacOS/Pomodoro" 2>/dev/null || true
else
    echo "Warning: Sparkle.framework not found. Auto-update will not work."
fi

# Ad-hoc sign embedded frameworks first, then the app
codesign --force --sign - "$APP_DIR/Frameworks/Sparkle.framework" 2>/dev/null || true
codesign --force --sign - --entitlements Pomodoro/Pomodoro.entitlements .build/Pomodoro.app

echo "Launching Pomodoro.app..."
open .build/Pomodoro.app
