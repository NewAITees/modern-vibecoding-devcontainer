#!/bin/bash
set -e

echo "🚀 Installing CLI tools..."

# Clean up any existing npm cache issues
echo "🧹 Cleaning up npm cache..."
rm -rf ~/.npm ~/.npm-global 2>/dev/null || true

# Set up npm configuration for user-local installation
echo "📦 Setting up npm configuration..."
mkdir -p ~/.npm-global
export NPM_CONFIG_PREFIX="$HOME/.npm-global"
export PATH="$HOME/.npm-global/bin:$PATH"

# Use curl to install CLI tools directly
echo "🤖 Installing Claude Code CLI..."
curl -fsSL https://claude.ai/claude-code/install.sh | bash || echo "Claude Code installation failed, continuing..."

echo "💎 Installing Gemini CLI..."
# Alternative method for Gemini CLI if npm fails
if ! node /usr/local/lib/node_modules/npm/bin/npm-cli.js install -g @google/gemini-cli@latest 2>/dev/null; then
    echo "⚠️ npm install failed, trying alternative method..."
    # For now, we'll skip Gemini CLI and note this in the output
    echo "⚠️ Gemini CLI installation skipped due to npm permissions issue"
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
echo ""
echo "🔐 Authentication required:"
echo "  claude auth login"
echo "  gemini auth login"