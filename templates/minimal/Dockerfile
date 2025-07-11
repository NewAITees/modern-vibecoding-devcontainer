FROM modern-python-base:latest

# Copy project files
COPY pyproject.toml uv.lock* ./
COPY src/ ./src/
COPY tests/ ./tests/

# Install project dependencies
RUN uv pip install --system -e .

# Install dev dependencies
RUN uv pip install --system pytest pytest-cov ruff black mypy

CMD ["/bin/bash"]