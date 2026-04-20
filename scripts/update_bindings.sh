#!/usr/bin/env bash
set -euo pipefail

RELEASE_URL="https://github.com/zkmopro/zkID/releases/download/latest/MoproAndroidBindings.zip"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
JNI_DIR="$REPO_ROOT/lib/src/main/jniLibs/arm64-v8a"
KOTLIN_DIR="$REPO_ROOT/lib/src/main/kotlin/uniffi/mopro"
TMP_DIR="$(mktemp -d)"

cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

echo "Downloading MoproAndroidBindings.zip..."
curl -fL "$RELEASE_URL" -o "$TMP_DIR/MoproAndroidBindings.zip"

echo "Extracting..."
unzip -q "$TMP_DIR/MoproAndroidBindings.zip" -d "$TMP_DIR/extracted"

# Copy .so files for arm64-v8a
SO_SRC=$(find "$TMP_DIR/extracted" -type d -name "arm64-v8a" | head -1)
if [ -n "$SO_SRC" ]; then
    echo "Updating arm64-v8a .so files..."
    cp "$SO_SRC"/*.so "$JNI_DIR/"
else
    echo "Warning: arm64-v8a directory not found in zip; skipping .so update"
fi

# Copy mopro.kt
KT_SRC=$(find "$TMP_DIR/extracted" -name "mopro.kt" | head -1)
if [ -n "$KT_SRC" ]; then
    echo "Updating mopro.kt..."
    cp "$KT_SRC" "$KOTLIN_DIR/mopro.kt"
else
    echo "Warning: mopro.kt not found in zip; skipping Kotlin update"
fi

echo "Done."
