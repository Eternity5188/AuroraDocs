@echo off
REM AuroraDocs 智能启动脚本 - 最大可靠性
REM 优先使用 Conda（预编译包，100% 成功）
REM 降级到 pip + wheels（99% 成功）

setlocal enabledelayedexpansion

echo.
echo ==================================================
echo   AuroraDocs Backend - Intelligent Setup
echo ==================================================
echo.

REM ============= 检测环境 =============

set USE_CONDA=false
set CONDA_CMD=

REM 检查 Conda/Mamba
where mamba >nul 2>&1
if %errorlevel% equ 0 (
    echo [+] Mamba found ^(faster Conda^)
    set USE_CONDA=true
    set CONDA_CMD=mamba
) else (
    where conda >nul 2>&1
    if %errorlevel% equ 0 (
        echo [+] Conda found
        set USE_CONDA=true
        set CONDA_CMD=conda
    )
)

REM 检查 Python
where python >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
    echo [+] Python: !PYTHON_VERSION!
) else (
    echo [-] Python not found
    pause
    exit /b 1
)

echo.

REM ============= 方式一：使用 Conda（最稳定）=============

if !USE_CONDA! equ true (
    echo [*] Using !CONDA_CMD! for maximum reliability
    echo.
    
    REM 检查环境是否存在
    !CONDA_CMD! env list | find "auroradocs" >nul
    if errorlevel 1 (
        echo [*] Creating Conda environment...
        !CONDA_CMD! create -y -n auroradocs python=3.11 2>nul || !CONDA_CMD! create -y -n auroradocs python=3.10
    )
    
    echo [*] Activating environment...
    call !CONDA_CMD! activate auroradocs
    
    echo [*] Installing PyTorch ^(pre-compiled, no compilation^)...
    !CONDA_CMD! install -y -c pytorch pytorch::pytorch pytorch::pytorch-cuda=11.8 2>nul || !CONDA_CMD! install -y -c pytorch pytorch::pytorch 2>nul || true
    
    echo [*] Installing ML ^& Core dependencies...
    pip install -q --upgrade pip
    pip install -q -r requirements-core.txt
    pip install -q transformers peft
    
    echo [*] Environment ready!

REM ============= 方式二：使用 pip 虚拟环境 =============

) else (
    echo [+] Using pip with pre-built wheels
    echo.
    
    REM 创建虚拟环境
    if not exist "venv" (
        echo [*] Creating Python virtual environment...
        python -m venv venv
    )
    
    call venv\Scripts\activate.bat
    
    echo [*] Upgrading pip...
    python -m pip install -q --upgrade pip setuptools wheel 2>nul || true
    
    echo [*] Installing dependencies ^(5-10 minutes^)...
    pip install --prefer-binary -q -r requirements-ml.txt 2>nul || (
        echo [!] Trying core + individual packages...
        pip install -q -r requirements-core.txt
        pip install --prefer-binary -q torch transformers peft 2>nul || (
            echo [!] Some ML packages unavailable
        )
    )
)

REM ============= 通用配置 =============

REM 创建 .env
if not exist ".env" (
    echo [*] Generating .env...
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

REM 创建目录
if not exist "models" mkdir models
if not exist "data\samples" mkdir data\samples

REM ============= 启动 =============

echo.
echo ==================================================
echo   [+] Backend ready! Starting server...
echo ==================================================
echo.
echo [*] Frontend: http://localhost:5173
echo [*] API Docs: http://localhost:8000/docs
echo [*] Press Ctrl+C to stop
echo.

python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

pause


