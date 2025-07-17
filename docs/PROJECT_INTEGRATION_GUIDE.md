# プロジェクト統合ガイド - Modern Python Development Environment

このガイドでは、構築したmodern-python-baseイメージを既存のプロジェクトや新規プロジェクトで効率的に活用する方法を説明します。

## 🎯 対象読者

- 既存のPythonプロジェクトにこの開発環境を導入したい開発者
- 新しいプロジェクトを効率的に開始したい開発者
- チーム開発で統一された開発環境を構築したい開発者

## 📋 前提条件

- Docker および Docker Compose がインストールされている
- modern-python-base イメージがビルド済みである
- 基本的なDockerの知識がある

## 🚀 クイックスタート

### 1. 新規プロジェクトの作成

```bash
# プロジェクトテンプレートから新規作成
./scripts/create-project.sh my-new-project minimal

# プロジェクトディレクトリに移動
cd ../my-new-project

# 開発環境を起動
docker compose up -d
docker compose exec dev bash
```

### 2. 既存プロジェクトへの統合

```bash
# 既存プロジェクトディレクトリで
# 1. Dockerfileを作成
cat > Dockerfile << 'EOF'
FROM modern-python-base:latest

WORKDIR /workspace
COPY requirements.txt .
RUN uv pip install -r requirements.txt

COPY . .
CMD ["tail", "-f", "/dev/null"]
EOF

# 2. Docker Composeファイルを作成
cat > compose.yml << 'EOF'
version: '3.8'
services:
  dev:
    build: .
    container_name: ${PROJECT_NAME:-myproject}-dev
    working_dir: /workspace
    volumes:
      - .:/workspace
      - dev-cache:/home/dev/.cache
    ports:
      - "8000:8000"
    stdin_open: true
    tty: true
    command: tail -f /dev/null

volumes:
  dev-cache:
EOF

# 3. 環境を起動
docker compose up -d
```

## 📁 プロジェクトタイプ別の統合方法

### Web アプリケーション（FastAPI/Flask）

```dockerfile
FROM modern-python-base:latest

WORKDIR /workspace

# 依存関係をインストール
COPY requirements.txt .
RUN uv pip install -r requirements.txt

# アプリケーションコードをコピー
COPY . .

# 開発サーバーを起動
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
```

```yaml
# compose.yml
version: '3.8'
services:
  web:
    build: .
    container_name: ${PROJECT_NAME:-webapp}-dev
    volumes:
      - .:/workspace
      - dev-cache:/home/dev/.cache
    ports:
      - "8000:8000"
    environment:
      - PYTHONPATH=/workspace
      - PYTHONUNBUFFERED=1
    depends_on:
      - db
      
  db:
    image: postgres:15
    environment:
      - POSTGRES_DB=myapp
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

volumes:
  dev-cache:
  postgres_data:
```

### データサイエンス プロジェクト

```dockerfile
FROM modern-python-base:latest

# Jupyter Lab と データサイエンス用パッケージをインストール
RUN uv pip install \
    jupyter \
    jupyterlab \
    pandas \
    numpy \
    matplotlib \
    seaborn \
    scikit-learn \
    plotly \
    ipywidgets

WORKDIR /workspace
COPY requirements.txt .
RUN uv pip install -r requirements.txt

COPY . .

EXPOSE 8888
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]
```

### CLI ツール開発

```dockerfile
FROM modern-python-base:latest

WORKDIR /workspace

# 依存関係をインストール
COPY requirements.txt .
RUN uv pip install -r requirements.txt

# パッケージをインストール（開発モード）
COPY . .
RUN uv pip install -e .

# CLIツールとして実行
ENTRYPOINT ["python", "-m", "your_package"]
```

### マイクロサービス開発

```dockerfile
FROM modern-python-base:latest

WORKDIR /app

# 依存関係をインストール
COPY requirements.txt .
RUN uv pip install -r requirements.txt

# アプリケーションコードをコピー
COPY . .

# ヘルスチェック
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## 🔧 VS Code Dev Container の統合

### .devcontainer/devcontainer.json の設定

```json
{
  "name": "Modern Python Development",
  "image": "modern-python-base:latest",
  "workspaceFolder": "/workspace",
  "mounts": [
    "source=${localWorkspaceFolder},target=/workspace,type=bind",
    "source=dev-cache,target=/home/dev/.cache,type=volume"
  ],
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-python.python",
        "ms-python.ruff",
        "ms-python.mypy-type-checker",
        "ms-python.black-formatter",
        "ms-python.pylint",
        "ms-toolsai.jupyter",
        "ms-vscode.vscode-json",
        "redhat.vscode-yaml",
        "GitHub.copilot"
      ],
      "settings": {
        "python.defaultInterpreterPath": "/usr/local/bin/python",
        "python.linting.enabled": true,
        "python.linting.ruffEnabled": true,
        "python.formatting.provider": "black",
        "python.testing.pytestEnabled": true,
        "python.testing.unittestEnabled": false,
        "python.testing.pytestPath": "/usr/local/bin/pytest",
        "files.watcherExclude": {
          "**/.git/objects/**": true,
          "**/.git/subtree-cache/**": true,
          "**/node_modules/**": true,
          "**/.venv/**": true,
          "**/__pycache__/**": true
        }
      }
    }
  },
  "postCreateCommand": "uv pip install -r requirements.txt && pre-commit install",
  "remoteUser": "dev",
  "forwardPorts": [8000, 8888],
  "portsAttributes": {
    "8000": {
      "label": "Application",
      "onAutoForward": "notify"
    },
    "8888": {
      "label": "Jupyter Lab",
      "onAutoForward": "openPreview"
    }
  }
}
```

## 🛠️ 開発ワークフロー

### 基本的な開発フロー

```bash
# 1. 開発環境を起動
docker compose up -d

# 2. 開発コンテナに接続
docker compose exec dev bash

# 3. 依存関係をインストール
uv pip install -r requirements.txt

# 4. プリコミットフックを設定
pre-commit install

# 5. 開発開始
# コード作成、テスト、デバッグ...

# 6. コード品質チェック
ruff check .
black .
mypy .

# 7. テスト実行
pytest --cov=src tests/

# 8. セキュリティチェック
safety check
bandit -r src/

# 9. 開発環境を停止
docker compose down
```

### AI CLI ツールの活用

```bash
# Claude Code CLI を使用
claude chat "このPythonコードを最適化して"

# Gemini CLI を使用
gemini chat "このエラーの原因を教えて"

# コード生成
claude generate "FastAPIでREST APIを作成"
```

## 📂 プロジェクト構成のベストプラクティス

### 推奨ディレクトリ構造

```
your-project/
├── .devcontainer/
│   └── devcontainer.json
├── .github/
│   └── workflows/
│       └── ci.yml
├── docs/
│   └── README.md
├── src/
│   └── your_package/
│       ├── __init__.py
│       ├── main.py
│       └── utils.py
├── tests/
│   ├── __init__.py
│   └── test_main.py
├── .gitignore
├── .pre-commit-config.yaml
├── Dockerfile
├── compose.yml
├── requirements.txt
├── requirements-dev.txt
└── pyproject.toml
```

### requirements.txt の例

```txt
# Web Framework
fastapi==0.104.1
uvicorn[standard]==0.24.0

# Database
sqlalchemy==2.0.23
alembic==1.13.1

# Utilities
pydantic==2.5.0
python-dotenv==1.0.0
```

### requirements-dev.txt の例

```txt
-r requirements.txt

# Development Tools (already in base image)
# pytest==7.4.3
# pytest-cov==4.1.0
# black==23.11.0
# ruff==0.1.6
# mypy==1.7.1

# Additional dev dependencies
httpx==0.25.2
pytest-asyncio==0.21.1
factory-boy==3.3.0
```

## 🔄 CI/CD 統合

### GitHub Actions の例

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Build development image
      run: docker build -t myapp-dev .
    
    - name: Run tests
      run: |
        docker run --rm myapp-dev pytest --cov=src tests/
    
    - name: Run code quality checks
      run: |
        docker run --rm myapp-dev ruff check .
        docker run --rm myapp-dev black --check .
        docker run --rm myapp-dev mypy .
    
    - name: Run security checks
      run: |
        docker run --rm myapp-dev safety check
        docker run --rm myapp-dev bandit -r src/
```

## 🏗️ 本番環境への展開

### プロダクション用 Dockerfile

```dockerfile
# マルチステージビルド
FROM modern-python-base:latest as builder

WORKDIR /app
COPY requirements.txt .
RUN uv pip install --no-cache-dir -r requirements.txt

# プロダクション用の軽量イメージ
FROM python:3.12-slim as production

# 必要なシステムパッケージのみインストール
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 非rootユーザーを作成
RUN useradd -m -s /bin/bash app

# Python パッケージをビルダーからコピー
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

WORKDIR /app
COPY --chown=app:app . .

USER app

# ヘルスチェック
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## 🔧 カスタマイズとトラブルシューティング

### 追加パッケージの永続化

```dockerfile
FROM modern-python-base:latest

# 追加のシステムパッケージ
USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    postgresql-client \
    redis-tools \
    && rm -rf /var/lib/apt/lists/*

# 追加のPythonパッケージ
USER dev
RUN uv pip install \
    psycopg2-binary \
    redis \
    celery

WORKDIR /workspace
```

### よくある問題と解決策

**問題 1: 権限エラー**
```bash
# 解決策: ユーザーIDを合わせる
docker run --user $(id -u):$(id -g) -v $(pwd):/workspace modern-python-base:latest
```

**問題 2: ポート競合**
```bash
# 解決策: 別のポートを使用
docker run -p 8001:8000 -v $(pwd):/workspace modern-python-base:latest
```

**問題 3: 依存関係の競合**
```bash
# 解決策: 依存関係を更新
uv pip install --upgrade package-name
```

## 🌟 高度な使用例

### マルチサービス開発環境

```yaml
# compose.yml
version: '3.8'
services:
  api:
    build: 
      context: ./api
      dockerfile: Dockerfile
    volumes:
      - ./api:/workspace
    ports:
      - "8000:8000"
    depends_on:
      - db
      - redis
      
  worker:
    build: 
      context: ./worker
      dockerfile: Dockerfile
    volumes:
      - ./worker:/workspace
    depends_on:
      - db
      - redis
      
  frontend:
    build: 
      context: ./frontend
      dockerfile: Dockerfile
    volumes:
      - ./frontend:/workspace
    ports:
      - "3000:3000"
      
  db:
    image: postgres:15
    environment:
      - POSTGRES_DB=myapp
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
      
  redis:
    image: redis:7-alpine
    
volumes:
  postgres_data:
```

### テスト環境の分離

```yaml
# compose.test.yml
version: '3.8'
services:
  test:
    build: .
    volumes:
      - .:/workspace
    environment:
      - PYTHONPATH=/workspace
      - TESTING=true
    depends_on:
      - test-db
    command: pytest --cov=src tests/
    
  test-db:
    image: postgres:15
    environment:
      - POSTGRES_DB=test_db
      - POSTGRES_USER=test
      - POSTGRES_PASSWORD=test
    tmpfs:
      - /var/lib/postgresql/data
```

## 📚 参考リソース

- [Docker Best Practices](https://docs.docker.com/develop/best-practices/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [VS Code Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers)
- [Python Package Management with uv](https://github.com/astral-sh/uv)
- [Modern Python Development](https://realpython.com/python-development-best-practices/)

---

このガイドを参考に、プロジェクトに最適な開発環境を構築してください。質問や改善提案がある場合は、プロジェクトのIssueトラッカーまでお知らせください。