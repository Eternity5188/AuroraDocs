#!/bin/bash

# AuroraDocs 一键启动脚本 - 自动处理所有配置

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo ""
echo "=================================================="
echo "  AuroraDocs Frontend - Auto Setup & Start"
echo "=================================================="
echo ""

# 检查 Node
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Please install Node.js 16+"
    exit 1
fi

echo "✓ Node.js detected: $(node --version)"
echo "✓ npm version: $(npm --version)"

# 安装依赖（如果需要）
if [ ! -d "node_modules" ]; then
    echo "✓ Installing dependencies..."
    npm install -q
fi

echo ""
echo "=================================================="
echo "  Frontend ready! Starting dev server..."
echo "=================================================="
echo ""
echo "📍 Open: http://localhost:5173"
echo "📍 Backend API: http://localhost:8000/docs"
echo "⏹  Press Ctrl+C to stop"
echo ""

npm run dev

