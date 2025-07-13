#!/bin/bash
set -e

echo "🚀 Installing CLI tools..."

# Set up npm configuration for user-local installation
echo "📦 Setting up npm configuration..."
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
export PATH="~/.npm-global/bin:$PATH"

# Install Claude Code CLI
if ! command -v claude &> /dev/null; then
    echo "🤖 Installing Claude Code CLI..."
    npm install -g @anthropic-ai/claude-code@latest
fi

# Install Gemini CLI
if ! command -v gemini &> /dev/null; then
    echo "💎 Installing Gemini CLI..."
    npm install -g @google/gemini-cli@latest
fi

# Install additional Python tools
echo "🐍 Installing additional Python tools..."
pip install --user pytest-cov pytest-mock vulture safety bandit

echo "✅ CLI tools installation complete!"
echo ""
echo "Available tools:"
echo "  - python $(python --version)"
echo "  - uv $(uv --version)"
echo "  - node $(node --version)"
echo "  - npm $(npm --version)"
echo "  - claude (Claude Code CLI)"
echo "  - gemini (Gemini CLI)"
echo ""
echo "📋 Add to your shell profile:"
echo "export PATH=\"~/.npm-global/bin:\$PATH\""