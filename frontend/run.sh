#!/bin/bash

# AuroraDocs 一键启动脚本 - 自动处理所有配置

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# 检查 Node
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Please install Node.js 16+"
    exit 1
fi

# 安装依赖（如果需要）
if [ ! -d "node_modules" ]; then
    npm install -q
fi

# 启动
echo ""
echo "🚀 启动 AuroraDocs 前端..."
echo "📍 访问 http://localhost:5173"
echo "❌ 按 Ctrl+C 停止"
echo ""

npm run dev

