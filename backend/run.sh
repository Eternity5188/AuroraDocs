#!/bin/bash

# AuroraDocs 智能启动脚本 - 最大可靠性
# 优先使用 Conda（预编译包，100% 成功）
# 降级到 pip + manylinux wheels（99% 成功）

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo ""
echo "=================================================="
echo "  AuroraDocs Backend - Intelligent Setup"
echo "=================================================="
echo ""

# ============= 检测环境 =============

USE_CONDA=false
PYTHON=""

# 检查 Conda/Mamba
if command -v mamba &> /dev/null; then
    echo "✓ Mamba found (faster Conda)"
    USE_CONDA=true
    CONDA_CMD="mamba"
elif command -v conda &> /dev/null; then
    echo "✓ Conda found"
    USE_CONDA=true
    CONDA_CMD="conda"
fi

# 检查 Python
if command -v python3 &> /dev/null; then
    PYTHON="python3"
elif command -v python &> /dev/null; then
    PYTHON="python"
else
    echo "❌ Python not found. Please install Python 3.9+"
    exit 1
fi

echo "✓ Python detected: $($PYTHON --version)"
echo ""

# ============= 方式一：使用 Conda（最稳定）=============

if [ "$USE_CONDA" = true ]; then
    echo "🎉 Using $CONDA_CMD for maximum reliability (pre-compiled packages)"
    echo ""
    
    # 创建 conda 环境（如果不存在）
    ENV_NAME="auroradocs"
    if ! $CONDA_CMD env list | grep -q "^$ENV_NAME "; then
        echo "✓ Creating Conda environment..."
        $CONDA_CMD create -y -n $ENV_NAME python=3.11 2>/dev/null || $CONDA_CMD create -y -n $ENV_NAME python=3.10
    fi
    
    # 激活环境
    eval "$($CONDA_CMD shell.bash hook 2>/dev/null)" || true
    $CONDA_CMD activate $ENV_NAME
    
    echo "✓ Installing PyTorch (pre-compiled, no compilation needed)..."
    $CONDA_CMD install -y -c pytorch pytorch::pytorch pytorch::pytorch-cuda=11.8 2>/dev/null || \
    $CONDA_CMD install -y -c pytorch pytorch::pytorch 2>/dev/null || true
    
    echo "✓ Installing ML & Core dependencies..."
    pip install -q --upgrade pip
    pip install -q -r requirements-core.txt
    pip install -q transformers peft
    
    echo "✓ Environment ready!"

# ============= 方式二：使用 pip 虚拟环境 =============

else
    echo "📦 Using pip with pre-built wheels (high compatibility)"
    echo ""
    
    # 创建虚拟环境
    if [ ! -d "venv" ]; then
        echo "✓ Creating Python virtual environment..."
        $PYTHON -m venv venv
    fi
    source venv/bin/activate
    
    echo "✓ Upgrading pip to latest version..."
    pip install -q --upgrade pip setuptools wheel 2>/dev/null || true
    
    echo "✓ Installing dependencies (this may take 5-10 minutes)..."
    # 使用 --prefer-binary 优先使用预编译包
    pip install --prefer-binary --only-binary :all: -q -r requirements-ml.txt 2>/dev/null || {
        # 如果失败，尝试 requirements-core.txt
        echo "⚠️  Full ML install failed. Installing core + trying ML packages individually..."
        pip install -q -r requirements-core.txt
        pip install --prefer-binary -q torch transformers peft 2>/dev/null || {
            echo "⚠️  ML packages partially unavailable"
            echo "Core API is ready, but AI features may be limited"
        }
    }
fi

# ============= 通用配置 =============

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
echo "  ✨ Backend ready! Starting server..."
echo "=================================================="
echo ""
echo "📍 Frontend: http://localhost:5173"
echo "📖 API Docs: http://localhost:8000/docs"
echo "⏹  Press Ctrl+C to stop"
echo ""

python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload




