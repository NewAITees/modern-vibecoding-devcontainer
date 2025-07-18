# Stage 1: Get Node.js binaries from official image
FROM node:20-slim as node-stage

# Stage 2: Build final image based on Python
FROM python:3.12-slim

# Set environment variables for Python and uv
ENV PATH="/home/dev/.local/bin:$PATH"
ENV PYTHONPATH="/workspace"
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV UV_CACHE_DIR="/tmp/uv-cache"
ENV UV_COMPILE_BYTECODE=1

# Copy complete Node.js installation from stage 1 (avoids apt-get issues)
COPY --from=node-stage /usr/local/bin/node /usr/local/bin/
COPY --from=node-stage /usr/local/bin/npm /usr/local/bin/
COPY --from=node-stage /usr/local/bin/npx /usr/local/bin/
COPY --from=node-stage /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node-stage /usr/local/include/node /usr/local/include/node
COPY --from=node-stage /usr/local/share/man/man1/node* /usr/local/share/man/man1/
# Fix npm symlinks
RUN ln -sf /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm && \
    ln -sf /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

# Install uv and basic system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && pip install uv

# Set working directory
WORKDIR /workspace

# Install CLI tools globally as root (before creating user)
RUN npm install -g @anthropic-ai/claude-code@latest || echo "Claude Code installation failed"
RUN npm install -g @google/gemini-cli@latest || echo "Gemini CLI installation failed"

# Create a non-root user
RUN useradd -m -s /bin/bash dev
RUN chown -R dev:dev /workspace
USER dev

# Install common Python development tools in user space
RUN pip install --user \
    pre-commit \
    pytest \
    pytest-cov \
    pytest-mock \
    ruff \
    black \
    mypy \
    vulture \
    safety \
    bandit

# Default command
CMD ["/bin/bash"]