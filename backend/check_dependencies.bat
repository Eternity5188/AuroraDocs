@echo off
REM AuroraDocs 依赖检查和修复脚本 (Windows)
REM 功能: 检查所有依赖，自动安装缺失包，升级版本不匹配的包

setlocal enabledelayedexpansion

echo.
echo ==================================================
echo   AuroraDocs - Dependency Checker ^& Fixer
echo ==================================================
echo.

REM ============= 激活环境 =============

echo [1/5] Activating Python environment...

REM 检查 Conda 环境
where conda >nul 2>&1
if %errorlevel% equ 0 (
    echo [+] Found Conda
    
    REM 查找 auroradocs 环境
    for /f "tokens=1" %%i in ('conda env list ^| find "auroradocs"') do set CONDA_ENV=%%i
    
    if "!CONDA_ENV!"=="" (
        echo [!] Conda environment 'auroradocs' not found
        echo Creating Conda environment...
        call conda create -y -n auroradocs python=3.11
        echo Please run this script again after environment creation
        pause
        exit /b 0
    )
    
    echo [+] Using Conda environment: auroradocs
    call conda activate auroradocs
) else if exist "venv\Scripts\activate.bat" (
    call venv\Scripts\activate.bat
    echo [+] Using venv environment
) else (
    echo [-] No Python environment found
    echo Run: run.bat ^(to setup environment first^)
    pause
    exit /b 1
)

python --version
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
