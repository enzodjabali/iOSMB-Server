# iOSMB-Server Build System

This document explains the build process for iOSMB-Server, which requires compiling Swift code for iOS.

## Architecture

The build process is split into two parts:

1. **Swift Binary Compilation** (requires macOS)
   - Compiles the main server binary from Swift source code
   - Produces a universal binary for arm64 + arm64e architectures
   - Output: `iOSMB-Server/Package/usr/bin/iOSMB-Server`

2. **Theos Compilation** (works on Linux via Docker)
   - Compiles the Objective-C tweak (`libiosmb.dylib`)
   - Compiles the preferences bundle (`iOSMB-Server.bundle`)
   - Packages everything into a `.deb` file

## Build Methods

### Method 1: GitHub Actions (Recommended)

Push a tag to trigger the automated build:

```bash
git tag v0.7.0
git push origin v0.7.0
```

This will:
1. Use a macOS runner to compile the Swift binary
2. Use an Ubuntu runner with Docker to compile Theos components
3. Create a GitHub Release with the `.deb` file attached

### Method 2: Local Build (Requires Mac + Linux/Docker)

#### Prerequisites for macOS Build

1. **Install Xcode** (not just Command Line Tools)
   - Download from Mac App Store or [Apple Developer](https://developer.apple.com/xcode/)
   - Ensure Xcode is the active developer directory:
     ```bash
     sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
     ```
   - Verify iOS SDK is available:
     ```bash
     xcrun --sdk iphoneos --show-sdk-path
     ```

2. **Install ldid** (for code signing)
   ```bash
   brew install ldid
   ```
   
3. **Accept Xcode License** (if not done already)
   ```bash
   sudo xcodebuild -license accept
   ```

#### Step 1: Build Swift binary on macOS

On a Mac with the prerequisites installed:

```bash
./build-swift-macos.sh
```

This creates: `iOSMB-Server/Package/usr/bin/iOSMB-Server`

#### Step 2: Build .deb package with Docker

On Linux (or Mac with Docker):

```bash
./build-docker.sh
```

This creates: `output/iOSMB-Server.deb`

### Method 3: Pre-compiled Binary

If you don't have access to a Mac:

1. Get someone with a Mac to run `./build-swift-macos.sh`
2. Commit the binary to git: `git add iOSMB-Server/Package/usr/bin/iOSMB-Server`
3. Run `./build-docker.sh` on Linux

**Note:** The binary is normally in `.gitignore`, so you'll need to force-add it if taking this approach.

## Files

- **Dockerfile** - Original Docker setup with Swift cross-compilation (experimental, doesn't work reliably)
- **Dockerfile.theos** - Production Dockerfile for Theos-only builds (expects pre-built Swift binary)
- **build-docker.sh** - Builds the `.deb` using Docker
- **build-swift-macos.sh** - Builds the Swift binary on macOS using xcodebuild (handles SPM dependencies)
- **.github/workflows/build.yml** - CI/CD pipeline using macOS + Linux runners (calls build-swift-macos.sh)

## Why Two Steps?

Swift cross-compilation from Linux to iOS is not officially supported by Apple and has many limitations:
- Module map conflicts between Linux Swift libraries and iOS SDK
- Missing iOS-specific frameworks (XPC, etc.)
- Complex toolchain setup with unreliable results

By using macOS for Swift compilation, we get:
- Official Apple toolchain support
- Reliable builds every time
- Access to all iOS frameworks
- Proper code signing with `ldid`

## Development Workflow

1. Make code changes
2. Test Swift compilation on Mac: `./build-swift-macos.sh`
3. Test full package build: `./build-docker.sh`
4. Commit and push changes
5. Create a tag for release: `git tag v0.x.x && git push origin v0.x.x`
6. GitHub Actions automatically:
   - Runs `./build-swift-macos.sh` on macOS runner (builds Swift binary)
   - Uploads binary as artifact
   - Runs `./build-docker.sh` on Linux runner (builds .deb with pre-compiled binary)
   - Creates GitHub release with .deb package

## Version Management

Use the version script to update version numbers:

```bash
./set-version.sh
# Enter version: 0.7.0
```

This updates:
- `iOSMB-Server/Package/DEBIAN/control`
- `libiosmb/control`

## Troubleshooting

### "Swift binary not found" error

The Swift binary must be built on macOS first. Either:
- Run `./build-swift-macos.sh` on a Mac
- Wait for GitHub Actions to build it
- Get a pre-compiled binary from someone

### Docker build fails

Make sure you have the Swift binary:
```bash
ls -lh iOSMB-Server/Package/usr/bin/iOSMB-Server
```

If missing, see "Swift binary not found" above.

### Binary has wrong port/old code

The binary is cached. Delete it and rebuild:
```bash
rm iOSMB-Server/Package/usr/bin/iOSMB-Server
./build-swift-macos.sh  # on Mac
```

### GitHub Actions build fails

Check the workflow logs:
1. Swift build job - macOS runner compiles Swift binary
2. Deb build job - Linux runner packages everything

If Swift build passes but Deb build fails, the binary artifact transfer may have failed.

## Project Structure

```
iOSMB-Server/
├── iOSMB-Server/              # Swift server source
│   ├── main.swift
│   ├── WebMessageServer.swift
│   ├── IPCSender.m
│   └── Package/
│       └── usr/bin/
│           └── iOSMB-Server   # Compiled binary (from macOS)
├── libiosmb/                  # Objective-C tweak
│   └── Tweak.x
├── iOSMBPreferences/          # Settings bundle
│   └── iOSMBRootListController.m
├── Dockerfile.theos           # Docker build (Theos only)
├── build-docker.sh            # Local build script
└── build-swift-macos.sh       # Swift compilation script
```

## Port Configuration

The server uses port **8190** by default (changed from 8180).

You can change this in:
- Source: `iOSMB-Server/WebMessageServer.swift` (line 35)
- Preferences: `iOSMBPreferences/Resources/Root.plist`
- After changing, rebuild the Swift binary on macOS

## License & Credits

Based on WebMessage by sgtaziz.
Modified for personal use by enzodjabali.
