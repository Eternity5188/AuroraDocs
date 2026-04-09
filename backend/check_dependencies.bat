@echo off
REM AuroraDocs 依赖检查和修复脚本 (Windows)
REM 功能: 检查所有依赖，自动安装缺失包，升级版本不匹配的包
REM 智能特性: 自动发现所有已有虚拟环境并让用户选择

setlocal enabledelayedexpansion
cd /d "%~dp0"

echo.
echo ==================================================
echo   AuroraDocs - Dependency Checker ^& Fixer
echo ==================================================
echo.

REM ============= 环境检测 =============

echo [0/5] Detecting Python environments...
echo.

set "env_count=0"
set "preferred_idx=-1"

REM 检测 Conda 环境
where conda >nul 2>&1
if %errorlevel% equ 0 (
    echo ^✓ Conda detected
    
    REM 获取 conda 环境列表
    for /f "tokens=1" %%A in ('conda env list ^| findstr /v "^#"') do (
        if not "%%A"=="" if not "%%A"=="name" (
            set /a env_count+=1
            set "env_name_!env_count!=%%A (conda)"
            
            REM 获取环境路径
            for /f "tokens=*" %%P in ('conda run -n %%A python -c "import sys; print(sys.prefix)" 2^>nul') do (
                set "env_path_!env_count!=%%P"
            )
            set "env_type_!env_count!=conda"
            
            REM 优先选择 auroradocs
            if "%%A"=="auroradocs" set "preferred_idx=!env_count!"
        )
    )
)

REM 检测本地 venv
if exist "venv\Scripts\activate.bat" (
    set /a env_count+=1
    set "env_name_!env_count!=venv (local)"
    set "env_path_!env_count!=%CD%\venv"
    set "env_type_!env_count!=venv"
)

if %env_count% equ 0 (
    echo [ERROR] No Python environments found!
    echo.
    echo Please create an environment first:
    echo   conda create -n auroradocs python=3.11
    echo   OR
    echo   python -m venv venv
    pause
    exit /b 1
)

echo ^✓ Found %env_count% environment(s):
echo.

REM 显示环境列表
for /l %%i in (1,1,%env_count%) do (
    echo   %%i !env_name_%%i!
    echo       Path: !env_path_%%i!
    
    REM 获取 Python 版本
    if !env_type_%%i! equ conda (
        set "python_exe=!env_path_%%i!\Scripts\python.exe"
    ) else (
        set "python_exe=!env_path_%%i!\Scripts\python.exe"
    )
    
    if exist "!python_exe!" (
        for /f "tokens=*" %%V in ('^"!python_exe!" --version 2^>^&1') do (
            echo       Python: %%V
        )
    )
    echo.
)

REM 自动选择（仅单个环境时）
if %env_count% equ 1 (
    set "selected_idx=1"
    echo ^✓ Auto-selected: !env_name_1!
) else (
    REM 多个环境时让用户选择
    :choose_env
    if %preferred_idx% geq 0 (
        set /p choice="Choose environment number (default: %preferred_idx%): "
        if "!choice!"=="" set "choice=%preferred_idx%"
    ) else (
        set /p choice="Choose environment number: "
    )
    
    REM 验证选择
    if !choice! geq 1 if !choice! leq %env_count% (
        set "selected_idx=!choice!"
        echo ^✓ Selected: !env_name_%selected_idx%!
    ) else (
        echo [ERROR] Invalid choice. Please try again.
        goto choose_env
    )
)

echo.
set "SELECTED_ENV_PATH=!env_path_%selected_idx%!"
set "SELECTED_ENV_TYPE=!env_type_%selected_idx%!"
set "PIP_EXE=!SELECTED_ENV_PATH!\Scripts\pip.exe"

if not exist "!PIP_EXE!" (
    echo [ERROR] pip not found at !PIP_EXE!
    pause
    exit /b 1
)

echo [1/5] Activating environment...
echo ^✓ Using pip: !PIP_EXE!
echo.

REM 激活对应的环境以便查看版本
if "!SELECTED_ENV_TYPE!"=="conda" (
    for /f "tokens=1" %%I in ("!SELECTED_ENV_PATH!") do (
        set "env_name=%%~nxI"
        call conda activate !env_name! >nul 2>&1
    )
) else if exist "!SELECTED_ENV_PATH!\Scripts\activate.bat" (
    call "!SELECTED_ENV_PATH!\Scripts\activate.bat" >nul 2>&1
)

"!SELECTED_ENV_PATH!\Scripts\python.exe" --version >nul 2>&1
echo.

REM ============= 检查依赖 =============

echo [2/5] Checking dependencies...
echo.

set missing_count=0
set wrong_version_count=0
set good_count=0

REM 创建临时 Python 脚本来检查依赖
(
    echo import pkg_resources
    echo import sys
    echo.
    echo packages = {
    echo     'fastapi': '==0.104.1',
    echo     'uvicorn': '==0.24.0',
    echo     'pydantic': '==2.5.0',
    echo     'pydantic-settings': '==2.1.0',
    echo     'sqlalchemy': '==2.0.23',
    echo     'alembic': '==1.13.1',
    echo     'psycopg2-binary': '==2.9.9',
    echo     'redis': '==5.0.1',
    echo     'celery': '==5.3.4',
    echo     'python-multipart': '==0.0.6',
    echo     'python-jose': '==3.3.0',
    echo     'passlib': '==1.7.4',
    echo     'python-dotenv': '==1.0.0',
    echo     'httpx': '==0.25.2',
    echo     'minio': '==7.2.0',
    echo     'transformers': '==4.35.2',
    echo     'torch': '==2.2.0',
    echo     'peft': '==0.6.2',
    echo }
    echo.
    echo missing = []
    echo wrong_version = []
    echo good = []
    echo.
    echo for pkg_name, expected_ver in packages.items():
    echo     try:
    echo         dist = pkg_resources.get_distribution(pkg_name)
    echo         installed_ver = dist.version
    echo         expected_clean = expected_ver.lstrip('=^<^>')
    echo         
    echo         if installed_ver == expected_clean:
    echo             print('[+] {}: {}'.format(pkg_name, installed_ver))
    echo             good.append(pkg_name)
    echo         else:
    echo             print('[!] {}: {} (need {})'.format(pkg_name, installed_ver, expected_clean))
    echo             wrong_version.append((pkg_name, expected_ver))
    echo     except pkg_resources.DistributionNotFound:
    echo         print('[-] {}: MISSING'.format(pkg_name))
    echo         missing.append((pkg_name, expected_ver))
    echo.
    echo print()
    echo print('Good: {}'.format(len(good)))
    echo print('Missing: {}'.format(len(missing)))
    echo print('Wrong version: {}'.format(len(wrong_version)))
    echo.
    echo if missing:
    echo     print('INSTALL: {}'.format(' '.join([x[0] for x in missing])))
    echo if wrong_version:
    echo     print('UPGRADE: {}'.format(' '.join([x[0] + x[1] for x in wrong_version])))
) > check_deps.py

python check_deps.py > deps_output.txt 2>&1

REM 解析输出并安装/升级
for /f "delims=" %%i in (deps_output.txt) do (
    if "%%i"=="" (
        set /a count=count
    ) else if "%%i:~0,6"=="INSTALL" (
        set install_list=%%i
    ) else if "%%i:~0,7"=="UPGRADE" (
        set upgrade_list=%%i
    ) else (
        echo %%i
    )
)

type deps_output.txt

REM 安装缺失的包
if not "!install_list!"=="" (
    echo.
    echo [3/5] Installing missing packages...
    echo.
    set packages_to_install=!install_list:INSTALL =!
    for %%p in (!packages_to_install!) do (
        echo [+] Installing %%p...
        pip install --prefer-binary "%%p" -q 2>nul || echo [!] Failed to install %%p
    )
)

REM 升级版本不匹配的包
if not "!upgrade_list!"=="" (
    echo.
    echo [4/5] Upgrading packages with wrong versions...
    echo.
    set packages_to_upgrade=!upgrade_list:UPGRADE =!
    for %%p in (!packages_to_upgrade!) do (
        echo [+] Upgrading %%p...
        pip install --prefer-binary "%%p" --upgrade -q 2>nul || echo [!] Failed to upgrade %%p
    )
)

REM 清理临时文件
del /f /q check_deps.py >nul 2>&1
del /f /q deps_output.txt >nul 2>&1

echo.
echo [5/5] Verification complete!
echo.
echo ==================================================
echo   All dependencies checked and fixed!
echo ==================================================
echo.
echo Next steps:
echo   1. Run: run.bat
echo   2. If issues remain: check error messages above
echo   3. For manual install: pip install -r requirements-ml.txt
echo.
pause
