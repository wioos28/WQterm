#!/usr/bin/env bash
set -euo pipefail

# WQTerm build script for Codemagic (macOS)
# Builds an unsigned .ipa using xcodebuild

PROJECT_NAME="WQTerm"
SCHEME_NAME="WQTerm"
CONFIGURATION="Release"
SDK="iphoneos"
DESTINATION="generic/platform=iOS"
ARCHIVE_PATH="build/${PROJECT_NAME}.xcarchive"
PAYLOAD_DIR="build/Payload"
IPA_PATH="build/${PROJECT_NAME}.ipa"

echo "=============================================="
echo " WQTerm Build Script (unsigned IPA)"
echo "=============================================="

# 1. Verify Xcode project exists
if [ ! -d "${PROJECT_NAME}.xcodeproj" ] && [ ! -d "${PROJECT_NAME}.xcworkspace" ]; then
  echo "[ERROR] Neither ${PROJECT_NAME}.xcodeproj nor ${PROJECT_NAME}.xcworkspace found."
  echo "Please create the Xcode project on macOS following PROJECT_SETUP.md"
  echo "and commit it to the repository before running this pipeline."
  exit 1
fi

# 2. Setup Xcode
echo "[1/4] Setting up Xcode..."
sudo xcode-select -switch /Applications/Xcode.app
xcodebuild -version

# 3. Build unsigned archive
echo "[2/4] Building unsigned archive..."
if [ -d "${PROJECT_NAME}.xcworkspace" ]; then
  xcodebuild \
    -workspace "${PROJECT_NAME}.xcworkspace" \
    -scheme "${SCHEME_NAME}" \
    -configuration "${CONFIGURATION}" \
    -sdk "${SDK}" \
    -destination "${DESTINATION}" \
    -archivePath "${ARCHIVE_PATH}" \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    ONLY_ACTIVE_ARCH=NO \
    archive
else
  xcodebuild \
    -project "${PROJECT_NAME}.xcodeproj" \
    -scheme "${SCHEME_NAME}" \
    -configuration "${CONFIGURATION}" \
    -sdk "${SDK}" \
    -destination "${DESTINATION}" \
    -archivePath "${ARCHIVE_PATH}" \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    ONLY_ACTIVE_ARCH=NO \
    archive
fi

# 4. Package IPA
echo "[3/4] Packaging IPA..."
rm -rf "${PAYLOAD_DIR}"
mkdir -p "${PAYLOAD_DIR}"
cp -R build/${PROJECT_NAME}.xcarchive/Products/Applications/${PROJECT_NAME}.app "${PAYLOAD_DIR}/"

cd build
zip -r "${PROJECT_NAME}.ipa" Payload
cd ..

echo "[4/4] Done!"
echo "IPA path: ${IPA_PATH}"
ls -lh "${IPA_PATH}"
