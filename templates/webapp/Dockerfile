FROM modern-python-base:latest

# Copy project files
COPY pyproject.toml uv.lock* ./
COPY src/ ./src/
COPY tests/ ./tests/

# Install project dependencies
RUN uv pip install --system -e .

# Install dev dependencies
RUN uv pip install --system pytest pytest-cov ruff black mypy httpx

# Expose port for FastAPI
EXPOSE 8000

# Default command to run the app
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]