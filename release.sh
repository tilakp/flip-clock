#!/usr/bin/env bash
# Build Release, install to /Applications, and package a distributable DMG in release/.
set -euo pipefail

cd "$(dirname "$0")"

SCHEME="flip-clock"
APP_NAME="flip-clock.app"
OUT="release"
DERIVED="$OUT/DerivedData"
STAGING="$OUT/staging"
DMG="$OUT/flip-clock-Installer.dmg"

echo "==> Building Release"
xcodebuild -project flip-clock.xcodeproj -scheme "$SCHEME" -configuration Release \
    -derivedDataPath "$DERIVED" clean build

APP="$DERIVED/Build/Products/Release/$APP_NAME"
[ -d "$APP" ] || { echo "Build did not produce $APP"; exit 1; }

echo "==> Installing to /Applications"
rm -rf "/Applications/$APP_NAME"
cp -R "$APP" /Applications/

echo "==> Packaging $DMG"
rm -rf "$STAGING" "$DMG"
mkdir -p "$STAGING"
cp -R "$APP" "$STAGING/"

if command -v create-dmg >/dev/null 2>&1; then
    create-dmg \
        --volname "Flip Clock" \
        --background "flip-clock.png" \
        --window-pos 200 120 \
        --window-size 800 400 \
        --icon-size 100 \
        --icon "$APP_NAME" 200 190 \
        --hide-extension "$APP_NAME" \
        --app-drop-link 600 185 \
        "$DMG" \
        "$STAGING/"
else
    echo "!! create-dmg not found - skipping DMG. Install it with: brew install create-dmg"
fi

rm -rf "$STAGING"
echo "==> Done. Installed /Applications/$APP_NAME"
[ -f "$DMG" ] && echo "    DMG: $DMG"
