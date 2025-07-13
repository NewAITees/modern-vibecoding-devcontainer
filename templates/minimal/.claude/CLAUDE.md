# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要
モダンなPython開発環境 - 包括的な開発ツールとベストプラクティスを備えたPythonプロジェクトテンプレート

## 技術スタック
- **Python 3.12+** with uv package manager
- **Code Quality**: ruff (linting + formatting), black (formatting), mypy (type checking)
- **Testing**: pytest, pytest-cov, pytest-mock
- **Security**: bandit, safety, vulture (dead code detection)
- **Development**: pre-commit hooks, devcontainer support
- **CI/CD**: GitHub Actions with comprehensive testing
- **Docker**: Multi-stage builds and development containers

## コーディング規約

### 必須ルール
- すべての関数・メソッドに型ヒントを必須とする
- Googleスタイルのdocstringを使用する
- pathlib.Pathを使用（os.pathは使用しない）
- 行長は100文字以内
- コードは必ずruffでフォーマットする

### 推奨ルール
- pydanticモデルを積極的に活用する
- 適切なエラーハンドリングを行う
- ログ出力を適切に行う
- セキュリティを意識したコードを書く

## Common Commands

### Development Setup
```bash
# Install dependencies
uv sync --all-extras --dev

# Set up pre-commit hooks
uv run pre-commit install

# Run development server
uv run python -m src.your_package
```

### Code Quality
```bash
# Format code
uv run ruff format .

# Lint code
uv run ruff check --fix .

# Type check
uv run mypy src/

# Find dead code
uv run vulture src/

# Security scan
uv run bandit -r src/
uv run safety check
```

### Testing
```bash
# Run tests
uv run pytest

# Run with coverage
uv run pytest --cov=src --cov-report=html

# Run specific test
uv run pytest tests/test_specific.py::test_function
```

### Docker
```bash
# Build and run development environment
docker compose up -d dev

# Execute commands in container
docker compose exec dev uv run pytest
```

## ファイル構造
```
project/
├── .github/workflows/    # GitHub Actions CI/CD
├── .devcontainer/        # VS Code Dev Container config
├── .claude/             # Claude Code configuration
├── src/your_package/    # Main package source code
├── tests/              # Test files
├── docs/               # Documentation
├── docker/             # Docker configurations
├── pyproject.toml      # Project configuration (managed by uv)
├── .pre-commit-config.yaml  # Pre-commit hooks
├── compose.yml         # Docker Compose services
└── README.md          # Project documentation
```

## 開発フロー
1. 新機能開発前に要件を明確化
2. テストファーストで開発
3. コードレビュー前にpre-commitを実行
4. 型チェック・リント・テストをすべて通す
5. セキュリティチェックを実行

## テスト方針
- すべての関数にテストを書く
- カバレッジ80%以上を目指す
- 境界値・異常系のテストを必ず含める
- モックを適切に使用する

## セキュリティ方針
- 環境変数で秘匿情報を管理
- SQLインジェクション対策を実施
- 入力値検証を必ず行う
- ログに秘匿情報を出力しない

## AI開発支援のルール
- 明確な要件定義を提供する
- 既存コードとの整合性を重視する
- セキュリティベストプラクティスを遵守する
- 保守性・可読性を重視する