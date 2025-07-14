# Easy Usage Guide - Modern Python Development Environment

このガイドでは、構築したベースイメージを最も簡単に使用する方法を説明します。

## 🚀 クイックスタート

### 1. 超簡単！ワンコマンド開発環境

```bash
# 便利なCLIツールをインストール
./scripts/install-dev-cli.sh

# 即座に開発開始！
./scripts/dev.sh shell

# または エイリアス使用（インストール後）
pydev shell
```

### 2. 基本的な使用方法

```bash
# 開発環境を起動（現在のディレクトリをマウント）
docker run -it --rm -v $(pwd):/workspace modern-python-base:latest

# バックグラウンドで起動
docker run -d --name my-dev -v $(pwd):/workspace modern-python-base:latest tail -f /dev/null

# 起動中のコンテナに接続
docker exec -it my-dev bash
```

### 3. CLIツールを使った簡単操作

```bash
# 開発環境管理
./scripts/dev.sh start myapp      # 名前付き環境を開始
./scripts/dev.sh run myapp        # バックグラウンドで実行
./scripts/dev.sh connect myapp    # 実行中の環境に接続
./scripts/dev.sh stop myapp       # 環境を停止
./scripts/dev.sh list             # 実行中の環境一覧
./scripts/dev.sh clean            # 停止済み環境を削除

# Web開発向け
./scripts/dev.sh web 8000         # ポート8000でWeb開発環境

# プロジェクト作成
./scripts/dev.sh create myapp webapp  # webappテンプレートから作成
```

### 4. テンプレートからプロジェクト作成

```bash
# 新しいプロジェクトを作成
./scripts/create-project.sh my-project minimal
cd my-project

# 開発環境を起動
docker compose up -d
docker compose exec dev bash
```

## 🛠️ 開発ツールの活用

### 利用可能なツール

**Python開発環境**:
- Python 3.12.11 + uv (高速パッケージマネージャー)
- pytest, pytest-cov, pytest-mock (テスト)
- ruff, black, mypy (コード品質)
- safety, bandit (セキュリティ)

**Node.js環境**:
- Node.js v20.19.3 + npm 10.8.2

**AIツール**:
- Claude Code CLI 1.0.51
- Gemini CLI 0.1.12

### 基本的な開発ワークフロー

```bash
# 1. プロジェクト開始
docker run -it --rm -v $(pwd):/workspace modern-python-base:latest

# 2. 依存関係管理
uv add requests fastapi
uv remove package-name

# 3. コード品質チェック
ruff check .
black .
mypy .

# 4. テスト実行
pytest --cov=src tests/

# 5. セキュリティチェック
safety check
bandit -r src/
```

## 📋 Dev Container CLI の使用

### インストール

```bash
# Dev Container CLI をインストール
npm install -g @devcontainers/cli

# または VS Code 経由でインストール
# Command Palette (F1) > "Dev Containers: Install devcontainer CLI"
```

### 使用方法

```bash
# 現在のディレクトリでdev containerを起動
devcontainer up --workspace-folder .

# dev container内でコマンド実行
devcontainer exec --workspace-folder . bash

# dev containerをビルド
devcontainer build --workspace-folder .
```

## 🎯 便利なワンライナー

### 開発環境の即座起動

```bash
# エイリアスを設定（~/.bashrc または ~/.zshrc に追加）
alias pydev='docker run -it --rm -v $(pwd):/workspace modern-python-base:latest'
alias pydev-bg='docker run -d --name pydev-$(basename $(pwd)) -v $(pwd):/workspace modern-python-base:latest tail -f /dev/null'
alias pydev-connect='docker exec -it pydev-$(basename $(pwd)) bash'
```

### プロジェクト固有の環境

```bash
# プロジェクト名でコンテナを起動
PROJECT_NAME=$(basename $(pwd))
docker run -it --rm --name dev-$PROJECT_NAME -v $(pwd):/workspace modern-python-base:latest

# ポートフォワーディング付きで起動（Web開発用）
docker run -it --rm -p 8000:8000 -v $(pwd):/workspace modern-python-base:latest
```

## 🔧 カスタマイズ

### 追加パッケージのインストール

```bash
# システムパッケージ（一時的）
apt-get update && apt-get install -y package-name

# Python パッケージ
uv add package-name

# Node.js パッケージ
npm install -g package-name
```

### 永続的なカスタマイズ

独自のDockerfileを作成:

```dockerfile
FROM modern-python-base:latest

# 追加のシステムパッケージ
USER root
RUN apt-get update && apt-get install -y \
    your-package \
    && rm -rf /var/lib/apt/lists/*

# 追加のPythonパッケージ
USER dev
RUN uv add your-python-package

# 追加の設定
COPY .your-config /home/dev/.your-config
```

## 🐳 Docker Compose での使用

### 基本的な docker-compose.yml

```yaml
version: '3.8'
services:
  dev:
    image: modern-python-base:latest
    container_name: ${PROJECT_NAME:-my-project}-dev
    working_dir: /workspace
    volumes:
      - .:/workspace
      - dev-cache:/home/dev/.cache
    ports:
      - "8000:8000"
      - "3000:3000"
    stdin_open: true
    tty: true
    command: tail -f /dev/null

volumes:
  dev-cache:
```

### 使用方法

```bash
# 環境変数でプロジェクト名を設定
export PROJECT_NAME=my-awesome-project

# 起動
docker compose up -d

# 接続
docker compose exec dev bash

# 停止
docker compose down
```

## 🌟 Tips & Best Practices

### 1. データの永続化

```bash
# キャッシュディレクトリをボリュームマウント
docker run -it --rm \
  -v $(pwd):/workspace \
  -v dev-cache:/home/dev/.cache \
  -v dev-uv:/home/dev/.local/share/uv \
  modern-python-base:latest
```

### 2. 環境変数の設定

```bash
# .env ファイルを使用
docker run -it --rm \
  -v $(pwd):/workspace \
  --env-file .env \
  modern-python-base:latest
```

### 3. ネットワーク設定

```bash
# 他のコンテナとの連携
docker network create dev-network
docker run -it --rm \
  --network dev-network \
  -v $(pwd):/workspace \
  modern-python-base:latest
```

### 4. VS Code Integration

`.devcontainer/devcontainer.json` を作成:

```json
{
  "name": "Modern Python Dev",
  "image": "modern-python-base:latest",
  "workspaceFolder": "/workspace",
  "mounts": [
    "source=${localWorkspaceFolder},target=/workspace,type=bind"
  ],
  "forwardPorts": [8000, 3000],
  "postCreateCommand": "echo 'Development environment ready!'",
  "remoteUser": "dev",
  "extensions": [
    "ms-python.python",
    "ms-python.black-formatter",
    "charliermarsh.ruff"
  ]
}
```

## 🔍 トラブルシューティング

### 一般的な問題と解決策

**権限エラー**:
```bash
# ユーザーIDを合わせる
docker run -it --rm \
  -v $(pwd):/workspace \
  --user $(id -u):$(id -g) \
  modern-python-base:latest
```

**ポートが使用中**:
```bash
# 別のポートを使用
docker run -it --rm -p 8001:8000 -v $(pwd):/workspace modern-python-base:latest
```

**コンテナが停止しない**:
```bash
# 強制停止
docker kill container-name
docker rm container-name
```

これで、Modern Python Development Environmentを簡単かつ効率的に使用できます！