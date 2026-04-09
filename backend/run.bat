@echo off
REM AuroraDocs 智能启动脚本 - 完全自动化
REM 自动安装 Conda（如果需要）+ 自动在 Conda 环境中使用 pip

setlocal enabledelayedexpansion

echo.
echo ==================================================
echo   AuroraDocs Backend - Intelligent Setup
echo ==================================================
echo.

REM ============= 强制使用 Conda（自动安装） =============

set USE_CONDA=false
set CONDA_CMD=
set CONDA_HOME=

REM 1. 检查是否已有 Conda/Mamba
where mamba >nul 2>&1
if !errorlevel! equ 0 (
    echo [+] Mamba found ^(faster Conda^)
    set USE_CONDA=true
    set CONDA_CMD=mamba
    for /f "tokens=*" %%i in ('where mamba') do set CONDA_BIN=%%i
) else (
    where conda >nul 2>&1
    if !errorlevel! equ 0 (
        echo [+] Conda found
        set USE_CONDA=true
        set CONDA_CMD=conda
        for /f "tokens=*" %%i in ('where conda') do set CONDA_BIN=%%i
    )
)

REM 2. 如果没有 Conda，自动安装 Miniconda
if !USE_CONDA! equ false (
    echo [!] Conda not found. Installing Miniconda automatically...
    echo.
    
    REM 设置安装位置
    set CONDA_HOME=%USERPROFILE%\miniconda3
    
    if exist "!CONDA_HOME!" (
        echo [+] Using existing Miniconda at !CONDA_HOME!
        set CONDA_CMD=!CONDA_HOME!\Scripts\conda
    ) else (
        echo [*] Downloading Miniconda installer...
        set INSTALLER_FILE=%TEMP%\miniconda_installer.exe
        
        REM 尝试使用 curl 或 PowerShell 下载
        where curl >nul 2>&1
        if !errorlevel! equ 0 (
            curl -fsSL "https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe" -o "!INSTALLER_FILE!"
        ) else (
            powershell -Command "Invoke-WebRequest -Uri 'https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe' -OutFile '!INSTALLER_FILE!'" || (
                echo [-] Failed to download Miniconda. Please install manually.
                echo [*] Download from: https://docs.conda.io/projects/miniconda/
                pause
                exit /b 1
            )
        )
        
        echo [*] Installing Miniconda...
        "!INSTALLER_FILE!" /S /D=!CONDA_HOME! >nul 2>&1
        del /f /q "!INSTALLER_FILE!"
        
        set CONDA_CMD=!CONDA_HOME!\Scripts\conda
        echo [+] Miniconda installed successfully!
    )
    
    set USE_CONDA=true
)

echo [+] Using Conda: !CONDA_CMD!
echo.

REM ============= 使用 Conda 创建和激活环境 =============

set ENV_NAME=auroradocs

REM 检查环境是否存在
!CONDA_CMD! env list | find "!ENV_NAME!" >nul
if errorlevel 1 (
    echo [*] Creating Conda environment ^(Python 3.11^)...
    !CONDA_CMD! create -y -n !ENV_NAME! python=3.11 2>nul || !CONDA_CMD! create -y -n !ENV_NAME! python=3.10
    echo [+] Environment created successfully!
) else (
    echo [+] Using existing Conda environment: !ENV_NAME!
)

echo [*] Activating environment...
call !CONDA_CMD! activate !ENV_NAME!

REM 验证激活
python --version >nul 2>&1
if errorlevel 1 (
    echo [-] Failed to activate Conda environment
    pause
    exit /b 1
)

echo [+] Current Python: 
python --version
echo.

REM ============= 检查环境是否完整安装了包 =============

REM 检查关键包是否已安装
python -c "import torch, transformers, fastapi, pydantic_settings" >nul 2>&1
if !errorlevel! equ 0 (
    echo [+] All required packages already installed in environment
    echo [+] Skipping package installation...
) else (
    echo [*] Installing packages in environment...
    
    echo [*] Installing PyTorch ^(pre-compiled, no compilation needed^)...
    !CONDA_CMD! install -y -c pytorch pytorch::pytorch pytorch::pytorch-cuda=11.8 2>nul || !CONDA_CMD! install -y -c pytorch pytorch::pytorch 2>nul || (
        echo [!] Installing PyTorch via pip as fallback...
        pip install --prefer-binary torch
    )
    
    echo [*] Installing ML ^& Core dependencies via pip in Conda env...
    pip install -q --upgrade pip setuptools wheel
    pip install -q -r requirements-core.txt
    pip install -q transformers peft
    
    echo [+] All packages installed successfully!
)

echo.


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
        echo CORS_ORIGINS=["http://localhost:5173","http://127.0.0.1:5173"]
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

set "PYTHONPATH=%CD%;%PYTHONPATH%"
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

pause



