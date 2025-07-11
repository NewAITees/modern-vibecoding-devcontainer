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

# Copy Node.js binaries and all related files from stage 1 (avoids apt-get issues)
COPY --from=node-stage /usr/local/bin/node /usr/local/bin/
COPY --from=node-stage /usr/local/bin/npm /usr/local/bin/
COPY --from=node-stage /usr/local/bin/npx /usr/local/bin/
COPY --from=node-stage /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node-stage /usr/local/include/node /usr/local/include/node
COPY --from=node-stage /usr/local/share/man/man1/node* /usr/local/share/man/man1/

# Install uv
RUN pip install uv

# Set working directory
WORKDIR /workspace

# Create a non-root user
RUN useradd -m -s /bin/bash dev
RUN chown -R dev:dev /workspace
USER dev

# Note: Python development tools will be installed later to avoid disk space issues
# See docs/CLI_INSTALLATION.md for installation instructions

# Default command
CMD ["/bin/bash"]