# CLI Tools Installation Guide

Due to current Docker build limitations (see [DOCKER_ISSUES.md](DOCKER_ISSUES.md)), CLI tools should be installed after container startup.

## 🚀 Quick Installation

### In Running Container

```bash
# Start the container
docker run -it modern-python-base:latest

# Install Node.js (for CLI tools)
curl -fsSL https://nodejs.org/dist/v20.11.0/node-v20.11.0-linux-x64.tar.xz | tar -xJ -C /usr/local --strip-components=1

# Install Claude Code CLI
curl -fsSL https://claude.ai/claude-code/install.sh | bash

# Install Gemini CLI
npm install -g @google/generative-ai-cli

# Install additional Python tools
pip install --user pytest-cov pytest-mock vulture safety bandit
```

## 📦 One-Line Setup Script

Create a setup script for convenience:

```bash
# Save as setup-cli.sh in your project
cat > setup-cli.sh << 'EOF'
#!/bin/bash
set -e

echo "🚀 Installing CLI tools..."

# Install Node.js
if ! command -v node &> /dev/null; then
    echo "📦 Installing Node.js..."
    curl -fsSL https://nodejs.org/dist/v20.11.0/node-v20.11.0-linux-x64.tar.xz | tar -xJ -C /usr/local --strip-components=1
fi

# Install Claude Code CLI
if ! command -v claude-code &> /dev/null; then
    echo "🤖 Installing Claude Code CLI..."
    curl -fsSL https://claude.ai/claude-code/install.sh | bash
fi

# Install Gemini CLI
if ! command -v gemini &> /dev/null; then
    echo "💎 Installing Gemini CLI..."
    npm install -g @google/generative-ai-cli
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
echo "  - claude-code (if installed successfully)"
echo "  - gemini (if installed successfully)"
EOF

chmod +x setup-cli.sh
```

## 🐳 Docker Compose Integration

Add CLI installation to your docker-compose.yml:

```yaml
services:
  dev:
    image: modern-python-base:latest
    volumes:
      - .:/workspace
      - ./setup-cli.sh:/usr/local/bin/setup-cli.sh
    working_dir: /workspace
    command: bash -c "setup-cli.sh && bash"
    environment:
      - PYTHONPATH=/workspace
```

## 🔧 Alternative: Custom Dockerfile

If you want to build a custom image with CLI tools:

```dockerfile
FROM modern-python-base:latest

USER root

# Install system dependencies if needed
RUN apt-get update --allow-unauthenticated && \
    apt-get install -y --allow-unauthenticated curl xz-utils && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl -fsSL https://nodejs.org/dist/v20.11.0/node-v20.11.0-linux-x64.tar.xz | \
    tar -xJ -C /usr/local --strip-components=1

USER dev

# Install CLI tools as user
RUN curl -fsSL https://claude.ai/claude-code/install.sh | bash && \
    npm install -g @google/generative-ai-cli

# Install additional Python tools
RUN pip install --user pytest-cov pytest-mock vulture safety bandit
```

## ⚠️ Troubleshooting

### Node.js Installation Issues
```bash
# If curl is not available, install it first
apt-get update --allow-unauthenticated
apt-get install -y --allow-unauthenticated curl xz-utils
```

### Permission Issues
```bash
# Ensure proper user permissions
sudo chown -R dev:dev /home/dev/.local
```

### Disk Space Issues
```bash
# Clean up Docker
docker system prune -a

# Check available space
df -h
```

## 📋 Verification

Test all tools are working:

```bash
# Python tools
python --version
uv --version
ruff --version
pytest --version

# Node.js tools
node --version
npm --version

# CLI tools
claude-code --version  # if installed
gemini --version       # if installed
```