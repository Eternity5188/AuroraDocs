@echo off
REM AuroraDocs 一键启动脚本 - 自动处理所有配置

setlocal enabledelayedexpansion

REM 找 Python
where python > nul 2>&1
if errorlevel 1 (
    where python3 > nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Python not found. Please install Python 3.9+
        pause
        exit /b 1
    )
    set "PYTHON=python3"
) else (
    set "PYTHON=python"
)

REM 创建虚拟环境
if not exist "venv" (
    %PYTHON% -m venv venv
)
call venv\Scripts\activate.bat

REM 选择安装模式
echo.
echo Select installation mode:
echo   1) Core (Fast, recommended for first time)
echo   2) Full ML (Includes transformers, torch, etc.)
echo.
set /p install_mode="Enter choice [1-2] (default: 1): "
if "%install_mode%"=="" set install_mode=1

if "%install_mode%"=="2" (
    echo [*] Installing full ML dependencies...
    set "REQUIREMENTS=requirements-ml.txt"
) else (
    echo [*] Installing core dependencies...
    set "REQUIREMENTS=requirements-core.txt"
)

REM 静默安装依赖
echo This may take several minutes...
python -m pip install -q --upgrade pip >nul 2>&1 || true
pip install -q -r !REQUIREMENTS! >nul 2>&1 || (
    echo [!] First attempt failed, retrying with full output...
    pip install -r !REQUIREMENTS!
)

REM 自动创建 .env（如果不存在）
if not exist ".env" (
    (
        echo DATABASE_URL=sqlite:///./auroradocs.db
        echo REDIS_URL=redis://localhost:6379/0
        echo MINIO_ENDPOINT=localhost:9000
        echo MINIO_ACCESS_KEY=minioadmin
        echo MINIO_SECRET_KEY=minioadmin
        echo MINIO_SECURE=false
        echo SECRET_KEY=your-secret-key-change-this
        echo ALGORITHM=HS256
        echo ACCESS_TOKEN_EXPIRE_MINUTES=30
        echo MODEL_BASE_PATH=./models
        echo SAMPLE_UPLOAD_PATH=./data/samples
        echo VLLM_HOST=localhost
        echo VLLM_PORT=8001
        echo CORS_ORIGINS=http://localhost:5173,http://127.0.0.1:5173
        echo VITE_API_BASE_URL=http://localhost:8000/api
    ) > .env
)

REM 创建数据和模型目录
if not exist "models" mkdir models
if not exist "data\samples" mkdir data\samples

REM 启动
echo.
echo [*] Starting AuroraDocs Backend...
echo [*] Visit http://localhost:8000/docs
echo [*] Press Ctrl+C to stop
echo.

python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

pause

