#!/bin/sh
# Builds the bundled `class-dump` binary as a universal (arm64 + x86_64) build of
# classdump-c (https://github.com/lechium/classdumpios), a class-dump fork that
# supports arm64 and LC_DYLD_CHAINED_FIXUPS binaries.
#
# The patches in this directory are applied on top of the pinned commit. They
# silence debug logging that classdump-c writes to stderr unconditionally, since
# Class Dumper treats any stderr output from class-dump as an error.
#
# Usage: contrib/classdump-c/build.sh

set -eu

UPSTREAM_URL="https://github.com/lechium/classdumpios.git"
UPSTREAM_COMMIT="7612735143cc739d03a066a3e66b48061bb6f57a"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

git clone --quiet "$UPSTREAM_URL" "$WORK_DIR/classdumpios"
cd "$WORK_DIR/classdumpios"
git checkout --quiet "$UPSTREAM_COMMIT"

for patch in "$SCRIPT_DIR"/*.patch; do
    git apply "$patch"
done

xcodebuild \
    -project classdumpc.xcodeproj \
    -scheme classdumpc-macos \
    -configuration Release \
    -derivedDataPath "$WORK_DIR/DerivedData" \
    ARCHS="arm64 x86_64" \
    ONLY_ACTIVE_ARCH=NO \
    MACOSX_DEPLOYMENT_TARGET=13.0 \
    CODE_SIGNING_ALLOWED=NO \
    build

# Replace rather than overwrite, so stale extended attributes (e.g. quarantine) aren't inherited
rm -f "$REPO_ROOT/class-dump"
cp "$WORK_DIR/DerivedData/Build/Products/Release/classdumpc" "$REPO_ROOT/class-dump"
file "$REPO_ROOT/class-dump"
