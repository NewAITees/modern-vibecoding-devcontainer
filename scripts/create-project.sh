#!/bin/bash
set -e

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <project-name> <template>"
    echo "Available templates: minimal, webapp, datascience, ml, cli"
    exit 1
fi

PROJECT_NAME=$1
TEMPLATE=$2
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🚀 Creating new Python project: $PROJECT_NAME"
echo "📦 Using template: $TEMPLATE"

# Create project directory
mkdir -p "../$PROJECT_NAME"
cd "../$PROJECT_NAME"

# Copy template files
if [ -d "$BASE_DIR/templates/$TEMPLATE" ]; then
    cp -r "$BASE_DIR/templates/$TEMPLATE/"* .
    echo "✅ Template files copied"
else
    echo "❌ Template '$TEMPLATE' not found"
    exit 1
fi

# Update project name in files
if [ -f "pyproject.toml" ]; then
    sed -i.bak "s/name = \".*\"/name = \"$PROJECT_NAME\"/" pyproject.toml
    rm pyproject.toml.bak 2>/dev/null || true
fi

echo "🎉 Project '$PROJECT_NAME' created successfully!"
echo ""
echo "Next steps:"
echo "1. cd ../$PROJECT_NAME"
echo "2. docker build -t $PROJECT_NAME-dev ."
echo "3. docker run -it --rm -v \$(pwd):/workspace $PROJECT_NAME-dev"