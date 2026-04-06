#!/bin/bash
set -e

echo "Building..."
swift build -c debug 2>&1

APP_DIR=".build/Pomodoro.app/Contents"
mkdir -p "$APP_DIR/MacOS"

cp .build/debug/Pomodoro "$APP_DIR/MacOS/Pomodoro"
cp Pomodoro/Info.plist "$APP_DIR/Info.plist"

# Add bundle identifier to Info.plist
/usr/libexec/PlistBuddy -c "Delete :CFBundleIdentifier" "$APP_DIR/Info.plist" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string com.pomodoro.app" "$APP_DIR/Info.plist"
/usr/libexec/PlistBuddy -c "Delete :CFBundleName" "$APP_DIR/Info.plist" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :CFBundleName string Pomodoro" "$APP_DIR/Info.plist"
/usr/libexec/PlistBuddy -c "Delete :CFBundlePackageType" "$APP_DIR/Info.plist" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :CFBundlePackageType string APPL" "$APP_DIR/Info.plist"
/usr/libexec/PlistBuddy -c "Delete :NSPrincipalClass" "$APP_DIR/Info.plist" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :NSPrincipalClass string NSApplication" "$APP_DIR/Info.plist"

echo "Launching Pomodoro.app..."
open .build/Pomodoro.app
