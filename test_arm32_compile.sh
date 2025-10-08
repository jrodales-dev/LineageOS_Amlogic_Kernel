#!/bin/bash
# Test script to verify ARM 32-bit compilation with olddefconfig using .configatv
# This script tests the configuration process without doing a full kernel build

set -e

echo "=== ARM 32-bit Kernel Configuration Test ==="
echo ""

# Check if .configatv exists
if [ ! -f ".github/workflows/.configatv" ]; then
    echo "ERROR: .github/workflows/.configatv not found!"
    exit 1
fi

echo "1. Cleaning previous configuration..."
make ARCH=arm mrproper 2>&1 | tail -5

echo ""
echo "2. Copying .configatv to .config..."
cp .github/workflows/.configatv .config

echo ""
echo "3. Running olddefconfig to update configuration..."
make ARCH=arm olddefconfig

echo ""
echo "4. Verifying configuration was generated..."
if [ -f ".config" ]; then
    echo "✓ .config file exists"
    echo "  Config file size: $(wc -l < .config) lines"
    echo "  Architecture: $(grep "^CONFIG_ARM=y" .config || echo "NOT FOUND")"
else
    echo "✗ .config file not found!"
    exit 1
fi

echo ""
echo "5. Checking for common ARM configuration options..."
grep "^CONFIG_ARM=y" .config > /dev/null && echo "✓ CONFIG_ARM=y is set" || echo "✗ CONFIG_ARM not set"
grep "^CONFIG_ARCH_MESON=y" .config > /dev/null && echo "✓ CONFIG_ARCH_MESON=y is set" || echo "  CONFIG_ARCH_MESON not set (may be optional)"

echo ""
echo "=== Configuration Test Complete ==="
echo ""
echo "The configuration has been successfully prepared using:"
echo "  - Source: .github/workflows/.configatv"
echo "  - Architecture: ARM 32-bit"
echo "  - Method: olddefconfig"
echo ""
echo "To compile the kernel, you would need to run:"
echo "  make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- uImage -j\$(nproc)"
