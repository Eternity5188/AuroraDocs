#!/bin/bash

# AuroraDocs 一键启动脚本 - 自动处理所有配置

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# ============= 自动检测和配置 =============

# 找 Python
if command -v python3 &> /dev/null; then
    PYTHON="python3"
elif command -v python &> /dev/null; then
    PYTHON="python"
else
    echo "❌ Python not found. Please install Python 3.9+"
    exit 1
fi

# 创建虚拟环境
if [ ! -d "venv" ]; then
    $PYTHON -m venv venv
fi
source venv/bin/activate

# 自动安装依赖（静默模式）
pip install -q --upgrade pip 2>/dev/null || true
pip install -q -r requirements.txt 2>/dev/null || {
    echo "⚠️ Dependency installation failed, retrying..."
    pip install -r requirements.txt
}

# 自动创建 .env（如果不存在）
if [ ! -f ".env" ]; then
    cat > .env << 'EOF'
DATABASE_URL=sqlite:///./auroradocs.db
REDIS_URL=redis://localhost:6379/0
MINIO_ENDPOINT=localhost:9000
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin
MINIO_SECURE=false
SECRET_KEY=your-secret-key-change-this
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
MODEL_BASE_PATH=./models
SAMPLE_UPLOAD_PATH=./data/samples
VLLM_HOST=localhost
VLLM_PORT=8001
CORS_ORIGINS=http://localhost:5173,http://127.0.0.1:5173
VITE_API_BASE_URL=http://localhost:8000/api
EOF
fi

# 创建数据和模型目录（如果不存在）
mkdir -p models data/samples

# ============= 启动 =============
echo ""
echo "🚀 启动 AuroraDocs 后端..."
echo "📍 访问 http://localhost:8000/docs"
echo "❌ 按 Ctrl+C 停止"
echo ""

python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload


