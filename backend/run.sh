#!/bin/bash

# AuroraDocs 智能启动脚本 - 最大可靠性
# 自动安装 Conda（如果需要）+ 自动激活环境中的 pip

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo ""
echo "=================================================="
echo "  AuroraDocs Backend - Intelligent Setup"
echo "=================================================="
echo ""

# ============= 强制使用 Conda（自动安装） =============

USE_CONDA=false
CONDA_CMD=""
CONDA_BIN_DIR=""

# 1. 检查是否已有 Conda/Mamba
if command -v mamba &> /dev/null; then
    echo "✓ Mamba found (faster Conda)"
    USE_CONDA=true
    CONDA_CMD="mamba"
    CONDA_BIN_DIR="$(dirname $(which mamba))"
elif command -v conda &> /dev/null; then
    echo "✓ Conda found"
    USE_CONDA=true
    CONDA_CMD="conda"
    CONDA_BIN_DIR="$(dirname $(which conda))"
fi

# 2. 如果没有 Conda，自动安装 Miniconda
if [ "$USE_CONDA" = false ]; then
    echo "⚠️  Conda not found. Installing Miniconda automatically..."
    
    # 检测操作系统
    OS_TYPE=$(uname -s)
    ARCH=$(uname -m)
    
    if [ "$OS_TYPE" = "Linux" ]; then
        if [ "$ARCH" = "x86_64" ]; then
            INSTALLER_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
        elif [ "$ARCH" = "aarch64" ]; then
            INSTALLER_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh"
        else
            echo "❌ Unsupported architecture: $ARCH"
            exit 1
        fi
    elif [ "$OS_TYPE" = "Darwin" ]; then
        if [ "$ARCH" = "x86_64" ]; then
            INSTALLER_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh"
        elif [ "$ARCH" = "arm64" ]; then
            INSTALLER_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh"
        else
            echo "❌ Unsupported architecture: $ARCH"
            exit 1
        fi
    else
        echo "❌ Unsupported OS: $OS_TYPE"
        exit 1
    fi
    
    # 安装 Miniconda 到 ~/.miniconda3
    CONDA_HOME="$HOME/.miniconda3"
    
    if [ -d "$CONDA_HOME" ]; then
        echo "✓ Using existing Miniconda installation at $CONDA_HOME"
        CONDA_CMD="$CONDA_HOME/bin/conda"
    else
        echo "📥 Downloading Miniconda..."
        INSTALLER_FILE="/tmp/miniconda_installer.sh"
        curl -fsSL "$INSTALLER_URL" -o "$INSTALLER_FILE"
        
        echo "📦 Installing Miniconda to ~/.miniconda3..."
        bash "$INSTALLER_FILE" -b -p "$CONDA_HOME"
        rm -f "$INSTALLER_FILE"
        
        CONDA_CMD="$CONDA_HOME/bin/conda"
        echo "✓ Miniconda installed successfully!"
    fi
    
    USE_CONDA=true
fi

echo "✓ Using Conda for installation: $CONDA_CMD"
echo ""

# ============= 使用 Conda 创建和激活环境 =============

ENV_NAME="auroradocs"

# 初始化 Conda shell
eval "$($CONDA_CMD shell.bash hook 2>/dev/null)" || true

# 检查环境是否存在（包括完整性检查）
if ! $CONDA_CMD env list | grep -q "^$ENV_NAME "; then
    echo "✓ Creating Conda environment (Python 3.11)..."
    $CONDA_CMD create -y -n $ENV_NAME python=3.11 2>/dev/null || $CONDA_CMD create -y -n $ENV_NAME python=3.10
    echo "✓ Environment created successfully!"
else
    echo "✓ Using existing Conda environment: $ENV_NAME"
fi

# 激活环境（这很关键！）
echo "✓ Activating environment..."
source $($CONDA_CMD info --base)/etc/profile.d/conda.sh
conda activate $ENV_NAME

echo "✓ Current Python: $(python --version)"
echo ""

# ============= 检查环境是否完整安装了包 =============

# 检查关键包是否已安装
if python -c "import torch, transformers, fastapi, pydantic_settings" 2>/dev/null; then
    echo "✓ All required packages already installed in environment"
    echo "✓ Skipping package installation..."
else
    echo "✓ Installing packages in environment..."
    
    echo "✓ Installing PyTorch (pre-compiled, no compilation needed)..."
    $CONDA_CMD install -y -c pytorch pytorch::pytorch pytorch::pytorch-cuda=11.8 2>/dev/null || \
    $CONDA_CMD install -y -c pytorch pytorch::pytorch 2>/dev/null || {
        echo "⚠️  Installing PyTorch via pip as fallback..."
        pip install --prefer-binary torch
    }
    
    echo "✓ Installing ML & Core dependencies via pip in Conda env..."
    pip install -q --upgrade pip setuptools wheel
    pip install -q -r requirements-core.txt
    pip install -q transformers peft
    
    echo "✓ All packages installed successfully!"
fi

echo ""


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





