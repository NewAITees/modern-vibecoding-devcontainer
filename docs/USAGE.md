# Modern Python Development Container 使い方

## 概要

このプロジェクトは、Python 3.12 + Node.js 20 をベースとした現代的な開発環境をDockerコンテナで提供します。
完全な開発ツールセット（linter、formatter、テストツール、セキュリティスキャナなど）が含まれています。

## 前提条件

- Docker Engine
- Docker Compose
- Git

## 初期セットアップ

### 1. 環境のビルド

```bash
# ベース環境のビルド
cd base
./build.sh
```

### 2. プロジェクトの作成

```bash
# プロジェクトテンプレートから新規プロジェクト作成
./scripts/create-project.sh <プロジェクト名> <テンプレート>

# 使用可能なテンプレート:
# - minimal: 基本的なPythonプロジェクト
# - webapp: FastAPI + SQLAlchemy Webアプリケーション
# - datascience: データサイエンス向け
# - ml: 機械学習プロジェクト
# - cli: CLIツール開発用
```

### 3. 開発コンテナの起動

```bash
# Docker Composeを使用した起動
docker compose up -d

# または個別にコンテナを起動
docker run -it --rm -v $(pwd):/workspace modern-python-base:latest
```

## 開発ワークフロー

### コンテナ内での開発

1. **コンテナに接続**
   ```bash
   docker exec -it <コンテナ名> /bin/bash
   ```

2. **パッケージ管理**
   ```bash
   # 依存関係のインストール
   uv pip install <package>
   
   # 開発依存関係のインストール
   uv pip install --dev <package>
   ```

3. **コード品質チェック**
   ```bash
   # フォーマット
   ruff format .
   black .
   
   # リント
   ruff check .
   
   # 型チェック
   mypy .
   
   # セキュリティスキャン
   safety check
   bandit -r .
   ```

4. **テスト実行**
   ```bash
   # テスト実行
   pytest
   
   # カバレッジレポート付きテスト
   pytest --cov=.
   ```

### VS Code Dev Container

1. **拡張機能のインストール**
   - Dev Containers拡張機能をインストール

2. **Dev Containerで開く**
   ```bash
   code .
   # コマンドパレット: "Dev Containers: Reopen in Container"
   ```

## CLI ツールの追加インストール

コンテナ起動後に以下のCLIツールを追加インストールできます：

```bash
# Claude Code CLI
curl -fsSL https://claude.ai/install.sh | bash

# Gemini CLI
npm install -g @google-ai/generativelanguage
```

詳細は [CLI_INSTALLATION.md](CLI_INSTALLATION.md) を参照してください。

## プロジェクト構成

```
modern-python-devenv/
├── base/                 # ベースDocker環境
│   ├── Dockerfile       # マルチステージビルド設定
│   ├── compose.yml      # Docker Compose設定
│   └── build.sh         # ビルドスクリプト
├── templates/           # プロジェクトテンプレート
│   ├── minimal/         # 基本テンプレート
│   ├── webapp/          # Webアプリテンプレート
│   └── ...
├── scripts/             # セットアップスクリプト
│   ├── create-project.sh
│   ├── install.sh
│   └── update-base.sh
└── docs/                # ドキュメント
```

## 環境の更新

```bash
# ベース環境の更新
./scripts/update-base.sh

# プロジェクトテンプレートの更新
git pull origin main
```

## トラブルシューティング

### Docker関連の問題

- [DOCKER_ISSUES.md](DOCKER_ISSUES.md) を参照してください

### 一般的な問題

1. **コンテナが起動しない**
   - Docker Engineが起動していることを確認
   - メモリ不足でないか確認

2. **依存関係の問題**
   - `uv pip install --upgrade pip` を実行
   - キャッシュクリア: `docker system prune -a`

3. **権限の問題**
   - ユーザーがdockerグループに属していることを確認
   - `sudo usermod -aG docker $USER`

## 利用可能なツール

### Python開発ツール
- **uv**: 高速パッケージマネージャー
- **ruff**: 高速リンター・フォーマッター
- **black**: コードフォーマッター
- **mypy**: 型チェッカー
- **pytest**: テストフレームワーク
- **pytest-cov**: カバレッジレポート

### セキュリティツール
- **safety**: 脆弱性チェッカー
- **bandit**: セキュリティリンター
- **vulture**: 未使用コード検出

### その他
- **pre-commit**: Git pre-commitフック
- **Node.js 20**: JavaScriptランタイム
- **npm/npx**: Node.jsパッケージマネージャー

## 次のステップ

1. プロジェクトテンプレートを使用して新規プロジェクトを作成
2. VS Code Dev Containerで開発環境を起動
3. 必要に応じてCLIツールを追加インストール
4. プロジェクト固有の設定を追加