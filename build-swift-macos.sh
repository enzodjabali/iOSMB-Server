#!/bin/bash

# Build script for compiling Swift binary on macOS
# This script should be run on a Mac with Xcode installed

set -e

echo "=========================================="
echo "iOSMB-Server Swift Binary Build (macOS)"
echo "=========================================="
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "ERROR: This script must be run on macOS"
    exit 1
fi

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "ERROR: Xcode is not installed"
    exit 1
fi

# Check if ldid is installed
if ! command -v ldid &> /dev/null; then
    echo "Installing ldid..."
    brew install ldid || {
        echo "ERROR: Could not install ldid. Please install it manually:"
        echo "  brew install ldid"
        exit 1
    }
fi

# Get the iOS SDK path
SDK_PATH=$(xcrun --sdk iphoneos --show-sdk-path)
echo "Using iOS SDK: $SDK_PATH"
echo ""

echo "Building with Xcode..."
# Build using xcodebuild to handle Swift Package Manager dependencies
# Skip libwebmesesage target which requires MonkeyDev/Theos
xcodebuild \
  -project iOSMB-Server.xcodeproj \
  -scheme WebMessage \
  -configuration Release \
  -sdk iphoneos \
  -arch arm64 -arch arm64e \
  -derivedDataPath build \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  BUILD_LIBRARY_FOR_DISTRIBUTION=NO \
  ONLY_ACTIVE_ARCH=NO \
  -skipMacroValidation \
  -skipPackagePluginValidation || {
    echo "Note: Build may have warnings but checking for binary..."
  }

echo ""
echo "Locating built binary..."
# Find the built binary
BUILT_BINARY=$(find build/Build/Products/Release-iphoneos -name "WebMessage" -type f | head -n 1)

if [ -z "$BUILT_BINARY" ]; then
    echo "ERROR: Could not find built binary"
    exit 1
fi

echo "Found binary at: $BUILT_BINARY"

# Copy to Package directory with correct name
mkdir -p iOSMB-Server/Package/usr/bin
cp "$BUILT_BINARY" iOSMB-Server/Package/usr/bin/iOSMB-Server

# Code sign the binary
echo "Code signing binary..."
ldid -S iOSMB-Server/Package/usr/bin/iOSMB-Server

echo ""
echo "=========================================="
echo "Build complete!"
echo "=========================================="
echo ""
echo "Binary info:"
ls -lh iOSMB-Server/Package/usr/bin/iOSMB-Server
file iOSMB-Server/Package/usr/bin/iOSMB-Server
lipo -info iOSMB-Server/Package/usr/bin/iOSMB-Server
echo ""
echo "Binary ready at: iOSMB-Server/Package/usr/bin/iOSMB-Server"
echo "You can now run ./build-docker.sh to build the complete .deb package"
