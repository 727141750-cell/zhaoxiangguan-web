@echo off
chcp 65001 >nul
echo ╔════════════════════════════════════════╗
echo ║   造像馆 - 一键部署脚本                  ║
echo ╚════════════════════════════════════════╝
echo.

REM 检查是否提供了服务器IP
if "%1"=="" (
    echo 使用方法: deploy.bat [服务器IP] [SSH端口]
    echo.
    echo 示例: deploy.bat 123.456.789.123 22
    echo.
    pause
    exit /b
)

set SERVER_IP=%1
set SSH_PORT=%2
if "%SSH_PORT%"=="" set SSH_PORT=22

echo 🌐 服务器IP: %SERVER_IP%
echo 🔑 SSH端口: %SSH_PORT%
echo.

REM 检查是否安装了SCP
where scp >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ 未找到SCP命令
    echo.
    echo 请安装OpenSSH客户端或使用Git Bash
    echo.
    echo 下载地址: https://git-scm.com/download/win
    echo.
    pause
    exit /b 1
)

echo ✅ 找到SCP命令
echo.

REM 创建远程目录
echo 📁 创建远程目录...
scp -P %SSH_PORT% -o StrictHostKeyChecking=no %~dp0deploy-server.sh root@%SERVER_IP%:/tmp/
if %errorlevel% neq 0 (
    echo ❌ 创建目录失败
    pause
    exit /b 1
)

echo ✅ 目录创建成功
echo.

REM 上传文件
echo 📤 上传文件到服务器...
scp -P %SSH_PORT% -o StrictHostKeyChecking=no %~dp0server-free.js root@%SERVER_IP%:/root/zhaoxiangguan/
if %errorlevel% neq 0 (
    echo ❌ 上传server-free.js失败
    pause
    exit /b 1
)

echo ✅ server-free.js 上传成功
echo.

scp -P %SSH_PORT% -o StrictHostKeyChecking=no %~dp0package.json root@%SERVER_IP%:/root/zhaoxiangguan/
if %errorlevel% neq 0 (
    echo ❌ 上传package.json失败
    pause
    exit /b 1
)

echo ✅ package.json 上传成功
echo.

REM 安装依赖并启动
echo 🔧 远程安装依赖并启动服务...
scp -P %SSH_PORT% -o StrictHostKeyChecking=no %~dp0server-free.js root@%SERVER_IP%:/root/zhaoxiangguan/
echo cd /root/zhaoxiangguan ^&^& npm install ^&^& pm2 start server-free.js --name zhaoxiangguan ^&^& pm2 save > remote_cmd.sh
chmod +x remote_cmd.sh
scp -P %SSH_PORT% -o StrictHostKeyChecking=no remote_cmd.sh root@%SERVER_IP%:/tmp/
ssh -p %SSH_PORT% -o StrictHostKeyChecking=no root@%SERVER_IP% "cd /root/zhaoxiangguan && npm install && pm2 start server-free.js --name zhaoxiangguan && pm2 save"

echo.
echo ╔════════════════════════════════════════╗
echo ║   部署完成！                            ║
echo ╚════════════════════════════════════════╝
echo.
echo 🌐 API地址: http://%SERVER_IP%:3001
echo 📱 请在Flutter中修改API地址
echo.
echo 📋 下一步:
echo 1. 访问 http://%SERVER_IP%:3001 测试API
echo 2. 修改Flutter中的API地址
echo 3. 构建APK: flutter build apk --release
echo 4. 在手机上测试应用
echo.
echo ⚠️  记得在腾讯云控制台开放3001端口！
echo.
pause
