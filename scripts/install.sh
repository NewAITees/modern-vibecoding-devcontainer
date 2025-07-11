#!/bin/bash
set -e

echo "🚀 Setting up Modern Python Development Environment..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

echo "✅ Docker is ready"

# Build base image
echo "🔨 Building base development image..."
cd base && ./build.sh

echo "🎉 Setup complete!"
echo ""
echo "Usage:"
echo "  Create new project: ./scripts/create-project.sh <name> <template>"
echo "  Update base image: ./scripts/update-base.sh"