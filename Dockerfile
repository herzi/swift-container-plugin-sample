# ================================
# Build image
# ================================
FROM swift:6.2

# Install OS updates and, if needed, sqlite3
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && rm -rf /var/lib/apt/lists/*

# Set up a build area
WORKDIR /build

RUN swift sdk install https://download.swift.org/swift-6.2-release/static-sdk/swift-6.2-RELEASE/swift-6.2-RELEASE_static-linux-0.0.1.artifactbundle.tar.gz --checksum d2225840e592389ca517bbf71652f7003dbf45ac35d1e57d98b9250368769378

# First just resolve dependencies.
# This creates a cached layer that can be reused
# as long as your Package.swift/Package.resolved
# files do not change.
COPY ./Package.* ./
RUN --mount=type=cache,target=/build/.build swift package resolve

COPY ./netrc ./netrc
# Copy entire repo into container
COPY ./Sources ./Sources

COPY ./Scripts ./Scripts
RUN --mount=type=cache,target=/build/.build sh Scripts/build-container.sh
RUN exit 1 # don't store anything in case this works
