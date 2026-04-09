@echo off
REM AuroraDocs 一键启动脚本 - 自动处理所有配置

setlocal enabledelayedexpansion

REM 检查 Node
where node > nul 2>&1
if errorlevel 1 (
    echo [ERROR] Node.js not found. Please install Node.js 16+
    pause
    exit /b 1
)

REM 安装依赖（如果需要）
if not exist "node_modules" (
    npm install -q
)

REM 启动
echo.
echo [*] Starting AuroraDocs Frontend...
echo [*] Visit http://localhost:5173
echo [*] Press Ctrl+C to stop
echo.

npm run dev

pause

