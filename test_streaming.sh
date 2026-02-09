#!/bin/bash
# Test script to compare memory usage before and after streaming implementation

set -e

echo "=== Testing Streaming Implementation ==="
echo ""

# Check if cargo is available
if ! command -v cargo &> /dev/null; then
    echo "ERROR: cargo not found. Please install Rust or activate the nix shell."
    echo "Try: nix develop"
    exit 1
fi

# Build the current version (with streaming)
echo "Building current version (with streaming)..."
cargo build --release --quiet
cp target/release/asciinema asciinema-streaming

# Checkout previous version (without streaming)
echo "Checking out previous version (without streaming)..."
git stash
git checkout HEAD~1 -- src/player.rs
cargo build --release --quiet
cp target/release/asciinema asciinema-original
git checkout src/player.rs
git stash pop || true

echo ""
echo "=== Test Files ==="
ls -lh large_test.cast

echo ""
echo "=== Testing with /usr/bin/time (if available) ==="

if command -v /usr/bin/time &> /dev/null; then
    echo ""
    echo "--- Original Version (with .collect()) ---"
    /usr/bin/time -v ./asciinema-original play --speed 1000 large_test.cast 2>&1 | grep -E "Maximum resident set|Elapsed"

    echo ""
    echo "--- Streaming Version (with spawn_blocking) ---"
    /usr/bin/time -v ./asciinema-streaming play --speed 1000 large_test.cast 2>&1 | grep -E "Maximum resident set|Elapsed"
else
    echo "WARNING: /usr/bin/time not available for detailed memory measurements"
    echo "You can manually test with:"
    echo "  ./asciinema-original play --speed 1000 large_test.cast"
    echo "  ./asciinema-streaming play --speed 1000 large_test.cast"
fi

echo ""
echo "=== Validation ==="
echo "Check that playback works correctly:"
echo "  ./asciinema-streaming play large_test.cast"
echo ""
echo "Press Ctrl+C to stop playback"
