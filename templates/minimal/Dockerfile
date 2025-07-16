FROM modern-python-base:latest

# Copy project files
COPY pyproject.toml ./
COPY README.md ./
COPY src/ ./src/
COPY tests/ ./tests/

# Dependencies will be installed at runtime with uv run
# This keeps the image lightweight and allows for dynamic dependency management

CMD ["/bin/bash"]