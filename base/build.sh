#!/bin/bash
set -e

echo "🚀 Building modern Python development base image..."

# Build the base image
docker build -t modern-python-base:latest .

echo "✅ Base image built successfully!"
echo "🐍 Python development environment is ready to use"
echo ""
echo "Next steps:"
echo "1. Create a new project: ../scripts/create-project.sh <project-name> <template>"
echo "2. Or use compose: docker compose up -d"