# ベースコンテナの他プロジェクトでの利用方法

## 概要

このプロジェクトで構築した `modern-python-base` コンテナを、他のプロジェクトのベースとして利用する方法を説明します。

## ベースコンテナの特徴

- **Python 3.12** + **Node.js 20** 環境
- **uv** パッケージマネージャー
- 完全な開発ツールセット（ruff、black、mypy、pytest、safety、banditなど）
- セキュリティスキャンツール
- Git、curl、ca-certificates

## 他プロジェクトでの利用方法

### 1. ベースコンテナの利用

他のプロジェクトの `Dockerfile` でベースコンテナを指定します：

```dockerfile
# プロジェクトのDockerfile
FROM modern-python-base:latest

# プロジェクト固有の設定
WORKDIR /app

# プロジェクトのファイルをコピー
COPY . .

# プロジェクト固有の依存関係をインストール
RUN uv pip install -r requirements.txt

# 追加の設定やツールのインストール
RUN apt-get update && apt-get install -y \
    your-additional-tools \
    && rm -rf /var/lib/apt/lists/*

# アプリケーションの起動
CMD ["python", "main.py"]
```

### 2. Docker Compose での利用

```yaml
# プロジェクトのcompose.yml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    image: your-project:latest
    container_name: your-project-app
    volumes:
      - .:/app
    ports:
      - "8000:8000"
    environment:
      - PYTHONPATH=/app
    depends_on:
      - db
      
  db:
    image: postgres:15
    environment:
      - POSTGRES_DB=your_db
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

### 3. マルチステージビルドでの利用

```dockerfile
# プロジェクトのDockerfile（マルチステージビルド）
FROM modern-python-base:latest as builder

WORKDIR /app
COPY requirements.txt .
RUN uv pip install --no-cache-dir -r requirements.txt

# プロダクション用の軽量イメージ
FROM python:3.12-slim as production

# ベースコンテナから必要なツールをコピー
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

WORKDIR /app
COPY . .

CMD ["python", "main.py"]
```

### 4. VS Code Dev Container での利用

プロジェクトの `.devcontainer/devcontainer.json`:

```json
{
  "name": "Your Project Dev Container",
  "image": "modern-python-base:latest",
  "workspaceFolder": "/workspace",
  "mounts": [
    "source=${localWorkspaceFolder},target=/workspace,type=bind"
  ],
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-python.python",
        "ms-python.ruff",
        "ms-python.mypy-type-checker",
        "ms-python.black-formatter"
      ],
      "settings": {
        "python.defaultInterpreterPath": "/usr/local/bin/python",
        "python.linting.enabled": true,
        "python.linting.ruffEnabled": true,
        "python.formatting.provider": "black"
      }
    }
  },
  "postCreateCommand": "uv pip install -r requirements.txt",
  "remoteUser": "dev"
}
```

## プロジェクト固有の設定例

### Web アプリケーション（FastAPI）

```dockerfile
FROM modern-python-base:latest

WORKDIR /app
COPY requirements.txt .
RUN uv pip install -r requirements.txt

COPY . .

EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### データサイエンス プロジェクト

```dockerfile
FROM modern-python-base:latest

# Jupyter Labのインストール
RUN uv pip install \
    jupyter \
    jupyterlab \
    pandas \
    numpy \
    matplotlib \
    seaborn \
    scikit-learn

WORKDIR /workspace
COPY . .

EXPOSE 8888
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]
```

### CLI ツール開発

```dockerfile
FROM modern-python-base:latest

WORKDIR /app
COPY requirements.txt .
RUN uv pip install -r requirements.txt

COPY . .
RUN uv pip install -e .

ENTRYPOINT ["your-cli-tool"]
```

## ベースコンテナの更新

### 1. ベースコンテナの更新

```bash
# ベースコンテナを更新
docker pull modern-python-base:latest

# または再ビルド
cd /path/to/modern-python-devenv/base
./build.sh
```

### 2. プロジェクトコンテナの再ビルド

```bash
# プロジェクトのコンテナを再ビルド
docker build --no-cache -t your-project:latest .

# またはDocker Composeで
docker compose build --no-cache
```

## 環境変数の設定

### 共通の環境変数

```bash
# .env ファイル
PYTHONPATH=/app
PYTHONUNBUFFERED=1
PYTHONDONTWRITEBYTECODE=1

# プロジェクト固有の環境変数
DATABASE_URL=postgresql://user:password@db:5432/your_db
API_KEY=your-api-key
DEBUG=true
```

### Dockerfile での設定

```dockerfile
FROM modern-python-base:latest

# 環境変数の設定
ENV PYTHONPATH=/app
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# プロジェクト固有の環境変数
ENV APP_ENV=production
ENV LOG_LEVEL=info
```

## ベストプラクティス

### 1. レイヤーキャッシュの活用

```dockerfile
FROM modern-python-base:latest

# 依存関係ファイルを先にコピー
COPY requirements.txt .
RUN uv pip install -r requirements.txt

# アプリケーションコードは後でコピー
COPY . .
```

### 2. セキュリティの考慮

```dockerfile
FROM modern-python-base:latest

# 非rootユーザーの使用
USER dev

# 必要最小限のファイルのみコピー
COPY --chown=dev:dev requirements.txt .
RUN uv pip install -r requirements.txt

COPY --chown=dev:dev . .
```

### 3. マルチ環境対応

```dockerfile
FROM modern-python-base:latest

# ARGで環境を指定
ARG ENV=production
ENV APP_ENV=${ENV}

# 環境に応じた設定
RUN if [ "$ENV" = "development" ]; then \
    uv pip install -r requirements-dev.txt; \
    else \
    uv pip install -r requirements.txt; \
    fi
```

## トラブルシューティング

### 1. ベースコンテナが見つからない

```bash
# ベースコンテナが存在するか確認
docker images | grep modern-python-base

# 存在しない場合は再ビルド
cd /path/to/modern-python-devenv/base
./build.sh
```

### 2. 依存関係の競合

```bash
# 依存関係を確認
uv pip list

# 競合を解決
uv pip install --upgrade <package>
```

### 3. 権限の問題

```dockerfile
# Dockerfileでユーザーを指定
USER dev

# またはruntime時に指定
docker run --user dev your-project:latest
```

## 参考リンク

- [Docker マルチステージビルド](https://docs.docker.com/develop/dev-best-practices/dockerfile_best-practices/#use-multi-stage-builds)
- [Docker Compose リファレンス](https://docs.docker.com/compose/compose-file/)
- [VS Code Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers)