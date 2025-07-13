# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
Modern Python Development Environment - A Docker-based Python development environment with uv package manager, full development toolset, and project templates for quick project creation.

## Architecture
- **Base Environment**: Python 3.12 + uv + development tools in Docker container
- **Template System**: Pre-configured project templates (minimal, webapp, datascience, ml, cli)
- **Script-based Setup**: Shell scripts for environment management and project creation
- **Multi-stage Docker Build**: Efficient container builds with Node.js integration

## Key Components

### Base Environment (`base/`)
- `Dockerfile`: Multi-stage build (Python 3.12 + Node.js 20)
- `compose.yml`: Docker Compose configuration
- `build.sh`: Base environment build script

### Templates (`templates/`)
- `minimal/`: Basic Python project with full development toolset
- `webapp/`: FastAPI + SQLAlchemy web application template
- Each template includes `Dockerfile`, `pyproject.toml`, and `CLAUDE.md`

### Scripts (`scripts/`)
- `create-project.sh`: Create new projects from templates
- `install.sh`: Initial environment setup
- `update-base.sh`: Update base environment

## Common Commands

### Environment Setup
```bash
# Initial setup
./scripts/install.sh

# Build base environment
cd base && ./build.sh

# Update base environment
./scripts/update-base.sh
```

### Project Creation
```bash
# Create new project
./scripts/create-project.sh <project-name> <template>

# Available templates: minimal, webapp, datascience, ml, cli
./scripts/create-project.sh my-project minimal
```

### Development Environment
```bash
# Build and run development container
docker build -t my-project-dev .
docker run -it --rm -v $(pwd):/workspace my-project-dev

# Using Docker Compose
docker compose up -d
```

### CLI Tools Installation
Due to Docker build limitations, CLI tools should be installed after container startup:
```bash
# Install Node.js, Claude Code CLI, and Gemini CLI
# See docs/CLI_INSTALLATION.md for detailed instructions
```

## Development Standards
- Python 3.12+ with uv package manager
- Type hints required for all functions
- Google-style docstrings
- Line length: 100 characters
- Code formatting with ruff
- Security scanning with safety and bandit
- Testing with pytest (80%+ coverage target)

## File Structure
```
modern-python-devenv/
├── base/                 # Base Docker environment
├── templates/            # Project templates
├── scripts/             # Setup and utility scripts
├── docs/                # Documentation
└── CLAUDE.md           # This file
```

## Important Notes
- Always use the script-based approach for project creation
- CLI tools (Claude Code, Gemini) must be installed post-container-startup
- Security is emphasized throughout with multiple scanning tools
- The environment supports both Docker and VS Code Dev Containers
- Templates are designed for immediate productivity with full toolchain