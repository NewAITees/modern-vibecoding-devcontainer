# 🐍 Modern Python Development Environment

[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![uv](https://img.shields.io/badge/uv-package%20manager-blue?style=for-the-badge)](https://github.com/astral-sh/uv)

> 🚀 **一度構築、どこでも開発** - モダンなPython開発環境をDocker + uvで実現

## ✨ 特徴

- 🔧 **フル開発ツールセット**: uv, ruff, pytest, mypy, vulture, safety, bandit
- 🐳 **Docker**による環境統一  
- 📦 **テンプレート**で即座にプロジェクト開始
- 💾 **容量効率**的な差分管理
- 🤖 **Claude Code**対応
- 🔄 **自動依存関係更新**: 週次で最新ライブラリに更新
- 🛡️ **セキュリティ重視**: pre-commit hooks + セキュリティスキャン
- 📋 **AI開発支援**: CLAUDE.mdによる開発ルール定義

## 🚀 クイックスタート

```bash
# 1. このリポジトリをクローン
git clone https://github.com/yourname/modern-python-devenv.git
cd modern-python-devenv

# 2. 環境セットアップ（初回のみ）
./scripts/install.sh

# 3. 新プロジェクト作成
./scripts/create-project.sh my-project minimal

# 4. 開発開始！
cd ../my-project
docker build -t my-project-dev .
docker run -it --rm -v $(pwd):/workspace my-project-dev
```

## 📁 プロジェクト構成

```
modern-python-devenv/
├── README.md                    # 使い方説明
├── LICENSE                      # MIT推奨
├── base/                        # ベース環境
│   ├── Dockerfile              # Python 3.12 + uv + 開発ツール
│   ├── compose.yml             # Docker Compose設定
│   └── build.sh                # ビルドスクリプト
├── templates/                   # プロジェクトテンプレート
│   ├── minimal/                # 最小構成
│   ├── webapp/                 # FastAPI + SQLAlchemy
│   ├── datascience/            # Pandas + Jupyter
│   ├── ml/                     # PyTorch + Transformers
│   └── cli/                    # Click + Rich
├── scripts/                     # ユーティリティスクリプト
│   ├── create-project.sh       # 新プロジェクト作成
│   ├── update-base.sh          # ベース更新
│   └── install.sh              # セットアップスクリプト
└── docs/                       # ドキュメント
```

## 🛠️ 利用可能なテンプレート

| テンプレート | 説明 | 主要パッケージ |
|-------------|------|---------------|
| `minimal` | 最小構成 + 全開発ツール | ruff, pytest, mypy, vulture, safety, bandit |
| `webapp` | Web API開発 | FastAPI, SQLAlchemy, Pydantic |
| `datascience` | データ分析 | Pandas, NumPy, Jupyter |
| `ml` | 機械学習 | PyTorch, Transformers, Scikit-learn |
| `cli` | CLI開発 | Click, Rich, Typer |

## 📖 使い方

### 新規プロジェクト作成

```bash
# 基本的な使い方
./scripts/create-project.sh <プロジェクト名> <テンプレート>

# 例: FastAPI Webアプリケーション
./scripts/create-project.sh my-api webapp

# 例: データサイエンスプロジェクト
./scripts/create-project.sh analysis datascience
```

### 開発環境起動

```bash
cd ../my-project

# Dockerで開発環境起動
docker build -t my-project-dev .
docker run -it --rm -v $(pwd):/workspace my-project-dev

# または VS Code Dev Containersを使用
code .  # .devcontainer/devcontainer.json が自動認識される
```

### ベース環境更新

```bash
# ベースイメージを最新に更新
./scripts/update-base.sh
```

## 🔧 カスタマイズ

### テンプレートの追加

1. `templates/` に新しいディレクトリを作成
2. 必要なファイルを配置
   - `Dockerfile`
   - `pyproject.toml`
   - `.devcontainer/devcontainer.json`
3. `scripts/create-project.sh` を更新

### ベース環境の変更

`base/Dockerfile` を編集して、共通で使用したいパッケージを追加:

```dockerfile
# 例: 追加パッケージのインストール
RUN uv pip install --system \
    pandas \
    requests \
    python-dotenv
```

## 🔄 自動依存関係更新

週次で自動的に依存関係を最新バージョンに更新します：

- **自動実行**: 毎週月曜日 9:00 UTC
- **手動実行**: GitHub Actionsから手動トリガー可能  
- **PR自動作成**: 更新内容をPRで確認・承認

## 🛡️ セキュリティ機能

### 組み込みセキュリティツール
- **safety**: 既知の脆弱性をチェック
- **bandit**: コードの潜在的セキュリティ問題を検出
- **pre-commit hooks**: コミット前の自動チェック

### セキュリティベストプラクティス
- 秘匿情報の環境変数管理
- 入力値検証の強制
- SQLインジェクション対策
- ログ出力時の秘匿情報除外

## 🚀 CI/CD対応

完全なCI/CDパイプラインを標準で提供：

```yaml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up uv
        uses: astral-sh/setup-uv@v4
      - name: Install dependencies
        run: uv sync --all-extras --dev
      - name: Run all checks
        run: |
          uv run ruff format --check .
          uv run ruff check .
          uv run mypy src/
          uv run vulture src/
          uv run safety check
          uv run bandit -r src/
          uv run pytest --cov=src
```

## 📋 要件

- Docker
- Git
- Bash (Windows の場合は WSL2 推奨)

## 🤝 貢献

1. Fork このリポジトリ
2. Feature branch作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Pull Request作成

## 📄 ライセンス

MIT License. 詳細は [LICENSE](LICENSE) を参照してください。

## 🙏 謝辞

- [uv](https://github.com/astral-sh/uv) - 高速なPythonパッケージマネージャ
- [ruff](https://github.com/charliermarsh/ruff) - 高速なPythonリンター
- [Docker](https://www.docker.com/) - コンテナ化プラットフォーム