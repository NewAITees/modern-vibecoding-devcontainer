# Base Development Environment

This directory contains the base Docker image for all Python development templates.

## Features

- Python 3.12 slim base
- uv package manager
- ruff linter & formatter
- pytest testing framework
- black code formatter
- mypy type checker
- ipython interactive shell
- pre-commit hooks

## Usage

```bash
# Build the base image
./build.sh

# Or use docker compose
docker compose up -d
```

## Image Details

- **Base Image**: python:3.12-slim
- **Package Manager**: uv
- **Development Tools**: ruff, pytest, black, mypy, ipython, pre-commit
- **User**: non-root user 'dev'
- **Working Directory**: /workspace