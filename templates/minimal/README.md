# Modern Python Project

A modern Python project template with comprehensive development tools and best practices.

## Features

- 🐍 **Python 3.12+** with uv package manager
- 🛠️ **Development Tools**: ruff, black, mypy, vulture, safety, bandit
- 🧪 **Testing**: pytest with coverage reporting
- 🔧 **Pre-commit Hooks**: Automated code quality checks
- 🐳 **Docker Support**: Multi-stage builds and dev containers
- 🚀 **CI/CD**: GitHub Actions with comprehensive testing
- 🤖 **AI Integration**: Claude Code and Gemini CLI with persistent storage

## Quick Start

### Using Docker (Recommended)

#### Option A: Docker Compose with CLI Tools
```bash
# Build and run development environment with persistent CLI tools
docker compose up -d dev

# Enter development container
docker compose exec dev bash

# Install CLI tools (first time only)
./setup-cli.sh

# Authenticate CLI tools (first time only)
claude auth login
gemini auth login

# Install dependencies
uv sync --all-extras --dev

# Run tests
uv run pytest
```

#### Option B: Enhanced CLI Script
```bash
# Start development environment with automatic CLI tool setup
./run-with-cli.sh

# CLI tools and authentication are automatically persistent
# Dependencies installation and development can start immediately
uv sync --all-extras --dev
```

### Local Development

```bash
# Install Python 3.12+ and uv
# https://docs.astral.sh/uv/getting-started/installation/

# Install dependencies
uv sync --all-extras --dev

# Set up pre-commit hooks
uv run pre-commit install

# Run tests
uv run pytest

# Run linting
uv run ruff check --fix .
uv run ruff format .
```

## Development Commands

```bash
# Code formatting
uv run ruff format .

# Linting with auto-fix
uv run ruff check --fix .

# Type checking
uv run mypy src/

# Find unused code
uv run vulture src/

# Security scanning
uv run bandit -r src/
uv run safety check

# Run tests with coverage
uv run pytest --cov=src --cov-report=html

# Run all pre-commit hooks
uv run pre-commit run --all-files
```

## Project Structure

```
├── .github/workflows/    # GitHub Actions CI/CD
├── .devcontainer/        # VS Code Dev Container config
├── .claude/             # Claude Code configuration
├── src/your_package/    # Main package source code
├── tests/              # Test files
├── docs/               # Documentation
├── docker/             # Docker configurations
├── setup-cli.sh        # CLI tools installation script
├── run-with-cli.sh     # Enhanced development environment launcher
├── pyproject.toml      # Project configuration
├── .pre-commit-config.yaml  # Pre-commit hooks
├── compose.yml         # Docker Compose services
└── README.md          # This file
```

## Configuration

### Code Quality Standards

- **Line Length**: 100 characters
- **Python Version**: 3.12+
- **Type Hints**: Required for all functions
- **Docstrings**: Google style required
- **Test Coverage**: 80%+ target

### Git Workflow

1. Create feature branch: `git checkout -b feature/your-feature`
2. Make changes and commit: `git commit -m "feat: add new feature"`
3. Push branch: `git push origin feature/your-feature`
4. Create Pull Request

### Pre-commit Hooks

Automatically runs on every commit:
- Code formatting (ruff)
- Linting (ruff)
- Type checking (mypy)
- Security checks (bandit)
- Dependency locking (uv)

## Docker Support

### Development Container

```bash
# Start development environment
docker compose up -d dev

# Execute commands in container
docker compose exec dev uv run pytest

# CLI tools are persistent across container restarts
docker compose exec dev claude --version
docker compose exec dev gemini --version
```

### CLI Tools Integration

The template includes two approaches for CLI tool integration:

#### Persistent Storage Benefits
- 🔧 **Configuration Persistence**: CLI settings preserved across container restarts
- 🔐 **Authentication Persistence**: Login tokens automatically saved
- 📦 **Project Isolation**: Each project maintains separate CLI environments
- ⚡ **Fast Startup**: No re-installation needed after first setup

### Production Build

```bash
# Build production image
docker build -t my-project .

# Run production container
docker run -p 8000:8000 my-project
```

## CI/CD

GitHub Actions automatically runs on push/PR:
- ✅ Code formatting check
- ✅ Linting
- ✅ Type checking
- ✅ Security scanning
- ✅ Test execution
- ✅ Coverage reporting

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.