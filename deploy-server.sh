#!/bin/bash

# 造像馆 - 快速部署脚本
# 适用于腾讯云服务器

echo "🚀 造像馆 - 快速部署开始..."

# 检查Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js未安装，正在安装..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt-get install -y nodejs
fi

echo "✅ Node.js版本: $(node --version)"

# 创建项目目录
mkdir -p /root/zhaoxiangguan
cd /root/zhaoxiangguan

# 安装依赖
echo "📦 安装依赖..."
npm init -y
npm install express node-fetch

# 创建uploads目录
mkdir -p uploads
mkdir -p public

# 复制服务器代码
echo "📝 复制服务器代码..."
# 这里需要手动上传 server-huggingface.js

# 安装PM2
echo "🔧 安装PM2..."
npm install -g pm2

# 开放防火墙端口
echo "🔥 配置防火墙..."
if command -v ufw &> /dev/null; then
    ufw allow 3001/tcp
    ufw reload
fi

echo "✅ 部署准备完成！"
echo ""
echo "📋 下一步："
echo "1. 上传 server-huggingface.js 到 /root/zhaoxiangguan/"
echo "2. 运行: pm2 start server-huggingface.js --name zhaoxiangguan"
echo "3. 运行: pm2 save"
echo ""
echo "🌐 服务器地址: http://$(hostname -I | awk '{print $1}'):3001"
