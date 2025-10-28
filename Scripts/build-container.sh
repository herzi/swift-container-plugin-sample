#!/bin/sh

set -o errexit
set -o nounset

if test "$(uname -o)" = "Darwin"; then
  toolchain_location="${HOME}/Library/Developer/Toolchains/swift-latest.xctoolchain/Info.plist"
  export TOOLCHAINS=$(plutil -extract CFBundleIdentifier raw "$toolchain_location")
  echo "TOOLCHAINS=${TOOLCHAINS}"
  # 'Apple Swift version 6.1.2 (swift-6.1.2-RELEASE)'
  swift_release="$(swift --version | head -n 1 | cut -d ' ' -f 5 | sed 's/^(//;s/)$//')"
else
  # 'Swift version 6.2 (swift-6.2-RELEASE)'
  swift_release="$(swift --version | head -n 1 | cut -d ' ' -f 4 | sed 's/^(//;s/)$//')"
fi

if test "${swift_release}" != 'swift-6.2-RELEASE'; then
  if test -n "${toolchain_location-}"; then
    echo "doesn't look like the swift open source toolchain: ${toolchain_location}"
    echo
    echo "Environment:"
    echo "  TOOLCHAINS='$TOOLCHAINS'"
  fi
  echo
  echo "compiler signature: $(swift --version | head -n 1)"
  echo "swift release:      $swift_release"
  echo
  echo "Follow these instructions for installation:"
  echo "  https://www.swift.org/install/macos/package_installer/"
  exit 1
fi
  
echo "Compiler:  $swift_release"

# swift-6.1.2-RELEASE_static-linux-0.0.1
sdk="$(swift sdk list | grep "${swift_release}_static-linux-" | head -n 1)"
if test -z "$sdk"; then
  echo
  echo "No SDK found for \`${swift_release}_static-linux-*\`"
  echo "SDKs present are:"
  swift sdk list | sort | while read sdk; do echo "- ${sdk}"; done
  echo
  echo "Follow these instructions for installation:"
  echo "  https://www.swift.org/documentation/articles/static-linux-getting-started.html"
  echo "  https://www.swift.org/install/macos/"
  exit 1
fi

echo "SDK:       $sdk"

set -o xtrace
swift package \
    --configuration release \
    --swift-sdk x86_64-swift-linux-musl \
    plugin \
    --allow-network-connections all \
    build-container-image \
    --netrc-file netrc \
    --product hello-world \
    --repository registry.digitalocean.com/hello-world/example
