#!/bin/bash
# Build script for easysend with EasyTier integration

set -e  # Exit on any error

echo "Building easysend with EasyTier integration..."

# First, verify that all required directories exist
if [ ! -d "easytier/easytier" ]; then
    echo "Error: EasyTier directory not found at easytier/easytier"
    exit 1
fi

if [ ! -d "core" ]; then
    echo "Error: Core directory not found at core"
    exit 1
fi

if [ ! -d "app/rust" ]; then
    echo "Error: Rust directory not found at app/rust"
    exit 1
fi

echo "All required directories exist."

# Build the Rust components
echo "Building Rust components..."
cd app/rust

# Check if we can compile the Rust code
if cargo check; then
    echo "Rust code compiles successfully!"
else
    echo "Error: Rust code does not compile"
    exit 1
fi

cd ../..

echo "Build verification completed successfully!"