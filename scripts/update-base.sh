#!/bin/bash
set -e

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🔄 Updating base development environment..."

cd "$BASE_DIR/base"

# Rebuild base image
docker build -t modern-python-base:latest . --no-cache

echo "✅ Base image updated successfully!"
echo "🚀 All projects using this base will use the updated environment on next build"