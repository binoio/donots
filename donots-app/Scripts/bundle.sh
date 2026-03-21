#!/usr/bin/env bash
set -euo pipefail

# bundle.sh: Package the built Donots binary into a macOS .app bundle

APP_NAME="Donots"
BUNDLE_ID="com.donots.app"
# Detect bin path from swift build
BIN_PATH=$(xcrun swift build -c release --show-bin-path)
BUILD_DIR="${BIN_PATH}"
BUNDLE_DIR="${BUILD_DIR}/${APP_NAME}.app"
CONTENTS_DIR="${BUNDLE_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

echo "Creating .app bundle..."
rm -rf "${BUNDLE_DIR}"
mkdir -p "${MACOS_DIR}" "${RESOURCES_DIR}"

# Copy binary
cp "${BUILD_DIR}/${APP_NAME}" "${MACOS_DIR}/${APP_NAME}"

# Copy Info.plist
cp "Resources/Info.plist" "${CONTENTS_DIR}/Info.plist"

# Determine version
VERSION="${APP_VERSION:-1.0.0}"
if [[ -z "${APP_VERSION:-}" && -f "../VERSION" ]]; then
    VERSION=$(tr -d '[:space:]' < "../VERSION")
elif [[ -z "${APP_VERSION:-}" && -f "VERSION" ]]; then
    VERSION=$(tr -d '[:space:]' < "VERSION")
fi

/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" "${CONTENTS_DIR}/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $VERSION" "${CONTENTS_DIR}/Info.plist"

# Copy entitlements
cp "Resources/Donots.entitlements" "${RESOURCES_DIR}/Donots.entitlements"

# Copy app icon
if [[ -f "Resources/Donots.icns" ]]; then
    cp "Resources/Donots.icns" "${RESOURCES_DIR}/Donots.icns"
fi

# Re-register with LaunchServices
/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -f "${BUNDLE_DIR}"

echo "✓ Build complete: ${BUNDLE_DIR}"
