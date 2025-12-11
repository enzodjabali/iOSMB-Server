# WebMessage Server

iOS tweak companion for iOSMB-Client.

WebMessage allows you to access your iMessages on any device through a web interface.

## What This Builds

- **libwebmessage.dylib**: MobileSubstrate tweak that hooks into Messages app

- **WebMessage binary**: Main server application  * This package has not been tested against iOS 12 fully. It is still in its early stages.

- **WebMessage.bundle**: Settings/preferences UI  

- **Package**: Complete .deb installer for jailbroken iOS devices

## Description

WebMessage is a tweak exposing a REST API (and a WebSocket) from your phone, allowing for SMS and iMessage functionality. To work, the client used and the phone must be on the same network. Alternatively, tunneling can also be used.

## Building

The current features are as follows:

### Prerequisites

- Docker installed ([Get Docker](https://docs.docker.com/get-docker/)) Sending attachments from your computer without needing to transfer it to your phone

- ~2GB free disk space Native notifications

* SSL encryption using your own privately generated certificate

### Build Command

```bash* Always-running daemon

./build-docker.sh* Ability to download all attachments through client

```

More features are planned in the future, such as reactions, read receipts, and more.

The `.deb` package will be created in `output/WebMessage.deb` (~832KB)

## Installation

## Build Instructions

1. **Transfer to your iPhone:**

```bash### Option 1: Docker Build (Recommended for Linux/Cross-platform)

scp output/WebMessage.deb mobile@YOUR-IPHONE-IP:/tmp/

```The easiest way to build the .deb package on any platform:



2. **SSH into your device and install:**```bash

```bash./build-docker.sh

ssh mobile@YOUR-IPHONE-IP```

sudo dpkg -i /tmp/WebMessage.deb

sudo apt-get install -f  # Fix dependencies if neededThe built package will be available in the `output/` directory.

```

For detailed Docker build instructions, see [DOCKER_BUILD.md](DOCKER_BUILD.md).

## Requirements

### Option 2: Native Build (macOS with Theos)

### Your iPhone Needs:

- iOS 12.0 or later (tested on iOS 14.8.1 and 15.1)If you have Theos installed locally:

- Jailbroken (any jailbreak: checkra1n, unc0ver, Taurine, etc.)

- Dependencies (auto-installed):```bash

  - `com.muirey03.libmryipc` (available on default repos)./build.sh

  - `mobilesubstrate````

  - `preferenceloader`

  - `openssl`Requirements:

- [Theos](https://theos.dev/docs/installation) installed at `/opt/theos` or `$HOME/theos`

### Build System Uses:- iOS SDKs from [theos/sdks](https://github.com/theos/sdks)

- Ubuntu 22.04 in Docker- MRYIPC headers installed in Theos

- Theos framework- dpkg-deb (install via Homebrew: `brew install dpkg`)

- iOS 13.7 SDK- ldid (install via Homebrew: `brew install ldid`)

- Clang 10 cross-compiler for arm64/arm64e

## Build Environment

## CompatibilityThis package uses [Theos](https://theos.dev/) for building the tweak components and [MonkeyDev](https://github.com/AloneMonkey/MonkeyDev/wiki/Installation) for the main binary.


Works on:
- iPhone 5s through iPhone 15 Pro Max
- iOS 12.0 - iOS 17.x
- All arm64/arm64e devices

## Troubleshooting

**Docker not found?**  
Install Docker: https://docs.docker.com/get-docker/

**Permission denied on build script?**  
```bash
chmod +x build-docker.sh
```

**Build fails with errors?**  
Remove old Docker images and rebuild:
```bash
docker rmi webmessage-builder:latest
./build-docker.sh
```

**Can't install on device?**  
Make sure `libmryipc` is installed first via Cydia/Sileo

## Features

- Real-time sending and receiving of messages
- Send attachments from your computer
- Native notifications
- SSL encryption with private certificates
- Password-protected
- Always-running daemon
- Download all attachments through client

## Credits

Original project: https://github.com/sgtaziz/WebMessage

If you would like to support the original author: https://paypal.me/sgtaziztweaks
