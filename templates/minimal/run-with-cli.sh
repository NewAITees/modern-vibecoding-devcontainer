#!/bin/bash
set -e

PROJECT_NAME=${1:-$(basename $(pwd))}
CONTAINER_NAME="dev-${PROJECT_NAME}"

echo "🚀 ${PROJECT_NAME} 開発環境を起動中..."

# 永続化ボリュームの確認・作成
docker volume create "${CONTAINER_NAME}-config" >/dev/null 2>&1 || true
docker volume create "${CONTAINER_NAME}-npm" >/dev/null 2>&1 || true

# コンテナの起動
docker run -it --rm \
    --name "${CONTAINER_NAME}" \
    -v "$(pwd):/workspace" \
    -v "${CONTAINER_NAME}-config:/home/dev/.config" \
    -v "${CONTAINER_NAME}-npm:/home/dev/.npm-global" \
    -e NPM_CONFIG_PREFIX="/home/dev/.npm-global" \
    -e PATH="/home/dev/.npm-global/bin:$PATH" \
    -p 8000:8000 \
    -p 3000:3000 \
    --init \
    modern-python-base:latest \
    bash -c '
        # 初回セットアップチェック
        if [ ! -f ~/.npm-global/.setup-complete ]; then
            echo "🔧 初回セットアップを実行中..."
            
            # npmの設定
            mkdir -p ~/.npm-global
            npm config set prefix "~/.npm-global"
            
            # Claude Code CLIのインストール
            echo "🤖 Claude Code CLIをインストール中..."
            npm install -g @anthropic-ai/claude-code@latest || echo "Claude Code installation failed"
            
            # Gemini CLIのインストール
            echo "💎 Gemini CLIをインストール中..."
            npm install -g @google/gemini-cli@latest || echo "Gemini CLI installation failed"
            
            # 追加のPythonツール
            echo "🐍 追加のPythonツールをインストール中..."
            pip install --user pytest-cov pytest-mock vulture safety bandit || echo "Python tools installation failed"
            
            # セットアップ完了マーク
            touch ~/.npm-global/.setup-complete
            echo "✅ セットアップ完了!"
        fi
        
        # 利用可能なツールの確認
        echo ""
        echo "🛠️ 利用可能なツール:"
        echo "  Python: $(python --version)"
        echo "  uv: $(uv --version)"
        echo "  Node.js: $(node --version 2>/dev/null || echo "未インストール")"
        echo "  npm: $(npm --version 2>/dev/null || echo "未インストール")"
        echo "  Claude CLI: $(claude --version 2>/dev/null || echo "未インストール")"
        echo "  Gemini CLI: $(gemini --version 2>/dev/null || echo "未インストール")"
        echo ""
        echo "📋 認証が必要な場合:"
        echo "  claude auth login"
        echo "  gemini auth login"
        echo ""
        
        # bashシェルの起動
        exec bash
    '