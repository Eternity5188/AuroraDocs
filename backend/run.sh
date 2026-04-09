#!/bin/bash

# AuroraDocs 一键启动脚本 - 自动处理所有配置

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo ""
echo "=================================================="
echo "  AuroraDocs Backend - Auto Setup & Start"
echo "=================================================="
echo ""

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

echo "✓ Python detected: $($PYTHON --version)"

# 创建虚拟环境
if [ ! -d "venv" ]; then
    echo "✓ Creating virtual environment..."
    $PYTHON -m venv venv
fi
source venv/bin/activate

# 选择安装模式
echo ""
echo "Select installation mode:"
echo "  1) Core (Fast, recommended for first time)"
echo "  2) Full ML (Includes transformers, torch, etc.)"
echo ""
read -p "Enter choice [1-2] (default: 1): " install_mode
install_mode=${install_mode:-1}

case $install_mode in
    2)
        echo "✓ Installing full ML dependencies..."
        REQUIREMENTS="requirements-ml.txt"
        ;;
    *)
        echo "✓ Installing core dependencies..."
        REQUIREMENTS="requirements-core.txt"
        ;;
esac

# 安装依赖
echo "This may take several minutes..."
pip install -q --upgrade pip 2>/dev/null || true
pip install -q -r "$REQUIREMENTS" 2>/dev/null || {
    echo "⚠️  First attempt failed, retrying with full output..."
    pip install -r "$REQUIREMENTS"
}

# 自动创建 .env（如果不存在）
if [ ! -f ".env" ]; then
    echo "✓ Generating .env configuration..."
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
echo "=================================================="
echo "  Backend ready! Starting server..."
echo "=================================================="
echo ""
echo "📍 Frontend: http://localhost:5173"
echo "📖 API Docs: http://localhost:8000/docs"
echo "⏹  Press Ctrl+C to stop"
echo ""

python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload



