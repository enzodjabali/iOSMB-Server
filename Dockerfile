# Dockerfile for building iOSMB-Server Sileo jailbreak tweak
# This builds the .deb package for iOS jailbroken devices

FROM ubuntu:22.04

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Set environment variables for Theos
ENV THEOS=/opt/theos
ENV PATH="${THEOS}/bin:${PATH}"

# Install required dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    make \
    perl \
    zip \
    unzip \
    build-essential \
    clang \
    libssl-dev \
    fakeroot \
    dpkg-dev \
    libplist-dev \
    libplist-utils \
    python3 \
    python3-pip \
    ca-certificates \
    wget \
    libtinfo5 \
    libncurses5 \
    rsync \
    && rm -rf /var/lib/apt/lists/*

# Install ldid (code signing tool) - build from source with all required libraries
RUN git clone https://github.com/ProcursusTeam/ldid.git /tmp/ldid && \
    cd /tmp/ldid && \
    make LDFLAGS="-lcrypto -lssl -lplist-2.0" && \
    cp -f ./ldid /usr/local/bin/ldid && \
    chmod +x /usr/local/bin/ldid && \
    cd / && \
    rm -rf /tmp/ldid

# Install Theos
RUN git clone --recursive https://github.com/theos/theos.git /opt/theos

# Install iOS toolchain for cross-compilation
RUN mkdir -p /opt/theos/toolchain && \
    cd /opt/theos/toolchain && \
    wget -q https://github.com/sbingner/llvm-project/releases/download/v10.0.0-1/linux-ios-arm64e-clang-toolchain.tar.lzma && \
    tar --lzma -xf linux-ios-arm64e-clang-toolchain.tar.lzma && \
    rm linux-ios-arm64e-clang-toolchain.tar.lzma && \
    mkdir -p linux/iphone && \
    mv ios-arm64e-clang-toolchain/* linux/iphone/ && \
    rmdir ios-arm64e-clang-toolchain && \
    find linux/iphone/bin -type f -exec chmod +x {} \;

# Download and install iOS SDKs (extract all then use iOS 13.7 which works with clang 10)
RUN mkdir -p /opt/theos/sdks && \
    cd /opt/theos/sdks && \
    curl -LO https://github.com/theos/sdks/archive/master.zip && \
    unzip -q master.zip && \
    mv sdks-master/* . && \
    rm -rf sdks-master master.zip && \
    # Remove iOS 14+ SDKs that have incompatible TBD format
    rm -rf iPhoneOS14.*.sdk iPhoneOS15.*.sdk iPhoneOS16.*.sdk iPhoneOS17.*.sdk

# Clone and install MRYIPC (dependency)
RUN git clone https://github.com/Muirey03/MRYIPC.git /tmp/MRYIPC && \
    cp -R /tmp/MRYIPC/*.h /opt/theos/vendor/include/ && \
    rm -rf /tmp/MRYIPC

# Copy the project's libmryipc library to theos
# This will be done after COPY . . to use the project's version

# Set working directory
WORKDIR /build

# Copy project files
COPY . .

# Copy the libmryipc library from the project to theos lib directory
RUN if [ -f /build/iOSMB-Server/Libraries/libmryipc.dylib ]; then \
        cp /build/iOSMB-Server/Libraries/libmryipc.dylib /opt/theos/lib/libmryipc.dylib; \
    fi

# Create a build script
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
echo "========================================"\n\
echo "Building libiosmb tweak..."\n\
echo "========================================"\n\
\n\
# Build libiosmb\n\
cd /build/libiosmb\n\
make clean || true\n\
make package FINALPACKAGE=1\n\
\n\
echo ""\n\
echo "========================================"\n\
echo "Building iOSMBPreferences bundle..."\n\
echo "========================================"\n\
\n\
# Build iOSMBPreferences\n\
cd /build/iOSMBPreferences\n\
make clean || true\n\
make FINALPACKAGE=1\n\
\n\
echo ""\n\
echo "========================================"\n\
echo "Copying built files to Package..."\n\
echo "========================================"\n\
\n\
# Ensure directories exist\n\
mkdir -p /build/iOSMB-Server/Package/Library/MobileSubstrate/DynamicLibraries\n\
mkdir -p /build/iOSMB-Server/Package/Library/PreferenceBundles\n\
\n\
# Remove old symlinks if they exist\n\
rm -f /build/iOSMB-Server/Package/Library/MobileSubstrate/DynamicLibraries/libiosmb.dylib\n\
rm -f /build/iOSMB-Server/Package/Library/MobileSubstrate/DynamicLibraries/libiosmb.plist\n\
rm -f /build/iOSMB-Server/Package/Library/PreferenceBundles/iOSMB-Server.bundle\n\
\n\
# Copy libiosmb files\n\
if [ -f /build/libiosmb/.theos/obj/libiosmb.dylib ]; then\n\
    cp /build/libiosmb/.theos/obj/libiosmb.dylib /build/iOSMB-Server/Package/Library/MobileSubstrate/DynamicLibraries/\n\
elif [ -f /build/libiosmb/.theos/obj/debug/libiosmb.dylib ]; then\n\
    cp /build/libiosmb/.theos/obj/debug/libiosmb.dylib /build/iOSMB-Server/Package/Library/MobileSubstrate/DynamicLibraries/\n\
fi\n\
\n\
cp /build/libiosmb/libiosmb.plist /build/iOSMB-Server/Package/Library/MobileSubstrate/DynamicLibraries/\n\
\n\
# Copy iOSMB-Server preferences bundle\n\
if [ -d /build/iOSMBPreferences/.theos/obj/iOSMB-Server.bundle ]; then\n\
    cp -r /build/iOSMBPreferences/.theos/obj/iOSMB-Server.bundle /build/iOSMB-Server/Package/Library/PreferenceBundles/\n\
elif [ -d /build/iOSMBPreferences/.theos/obj/debug/iOSMB-Server.bundle ]; then\n\
    cp -r /build/iOSMBPreferences/.theos/obj/debug/iOSMB-Server.bundle /build/iOSMB-Server/Package/Library/PreferenceBundles/\n\
fi\n\
\n\
echo ""\n\
echo "========================================"\n\
echo "Building final .deb package..."\n\
echo "========================================"\n\
\n\
# Build the final .deb package\n\
cd /build\n\
rm -f iOSMB-Server.deb\n\
dpkg-deb --root-owner-group -b iOSMB-Server/Package iOSMB-Server.deb\n\
\n\
echo ""\n\
echo "========================================"\n\
echo "Build complete!"\n\
echo "========================================"\n\
echo ""\n\
dpkg-deb --info iOSMB-Server.deb\n\
echo ""\n\
echo "Package size:"\n\
ls -lh iOSMB-Server.deb\n\
echo ""\n\
echo "Package contents:"\n\
dpkg-deb --contents iOSMB-Server.deb\n\
' > /build/build.sh && chmod +x /build/build.sh

# Set the default command
CMD ["/build/build.sh"]
