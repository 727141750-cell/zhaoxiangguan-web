# 造像馆 - 快速部署指南

## 🎯 3分钟完成部署

### 前置要求
- ✅ 腾讯云服务器（已有）
- ✅ 备案和软著（已完成）
- ✅ 服务器安装了Node.js

### 部署步骤

#### 1. 上传文件到服务器

**方法A：使用SCP（推荐）**
```bash
# 在本地Windows PowerShell中运行
scp E:\code\zhaoxiangguan\server-free.js root@your-server-ip:/root/zhaoxiangguan/
scp E:\code\zhaoxiangguan\package.json root@your-server-ip:/root/zhaoxiangguan/
```

**方法B：使用SFTP工具**
- 下载 WinSCP 或 FileZilla
- 连接到您的腾讯云服务器
- 上传 `server-free.js` 和 `package.json` 到 `/root/zhaoxiangguan/`

**方法C：直接在服务器上创建**
```bash
# SSH登录服务器
ssh root@your-server-ip

# 创建目录
mkdir -p /root/zhaoxiangguan
cd /root/zhaoxiangguan

# 创建文件（复制粘贴内容）
nano server-free.js
# 粘贴代码，按Ctrl+O保存，Ctrl+X退出

nano package.json
# 粘贴代码，按Ctrl+O保存，Ctrl+X退出
```

#### 2. 安装依赖并启动

```bash
# SSH登录服务器
ssh root@your-server-ip

# 进入目录
cd /root/zhaoxiangguan

# 安装依赖
npm install

# 启动服务
npm start

# 或者使用PM2（推荐，保持后台运行）
npm install -g pm2
pm2 start server-free.js --name zhaoxiangguan
pm2 save
pm2 startup
```

#### 3. 配置防火墙

**在腾讯云控制台**：
1. 登录腾讯云控制台
2. 进入"云服务器" → 实例
3. 点击您的服务器
4. "安全组" → "配置规则"
5. 添加规则：
   - 类型: 自定义
   - 来源: 0.0.0.0/0
   - 协议端口: TCP:3001
   - 策略: 允许

#### 4. 测试API

在浏览器访问：
```
http://your-server-ip:3001
```

应该看到API服务页面。

#### 5. 测试生成接口

```bash
curl -X POST http://your-server-ip:3001/api/generate \
  -H "Content-Type: application/json" \
  -d '{"style":"写真","substyle":"日系清新"}'
```

#### 6. 修改Flutter应用

打开 `lib/services/api_service.dart`：

```dart
class ApiService {
  // 修改为您的服务器IP
  static const String baseUrl = 'http://your-server-ip:3001';

  // ... 其他代码不变
}
```

#### 7. 构建APK

```bash
cd com_zhaoxiangguan_app
flutter build apk --release
```

APK文件位置：
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🔥 Hugging Face API密钥（可选，提高限额）

### 获取免费API密钥

1. **注册Hugging Face**
   - 访问：https://huggingface.co
   - 免费注册

2. **创建Access Token**
   - 点击头像 → Settings
   - Access Tokens → New token
   - 类型: Read
   - 复制token

3. **配置到服务器**

```bash
# SSH登录服务器
ssh root@your-server-ip

# 编辑环境变量
cd /root/zhaoxiangguan
nano .env

# 添加以下内容：
HF_API_KEY=your_huggingface_token_here

# 保存后重启服务
pm2 restart zhaoxiangguan
```

### 有密钥的好处
- ✅ 更高的请求限额
- ✅ 更快的响应速度
- ✅ 不会被限流

---

## 📊 免费API说明

### Hugging Face Inference API（推荐）

**优点**：
- ✅ 完全免费
- ✅ 无需GPU
- ✅ 自动扩容
- ✅ 使用Stable Diffusion XL
- ✅ 效果优秀

**限制**：
- 每月约1000-5000次请求（取决于模型）
- 并发限制：1-2个同时请求
- 响应时间：10-30秒

**对小应用完全够用！**

### 如果需要更多

可以轻松切换到：
1. Replicate API（按次付费）
2. AutoDL GPU服务器（按需租用）
3. 自己部署SD（需要GPU服务器）

---

## 🎨 生成效果说明

### 稳定运行配置
- **模型**: Stable Diffusion XL
- **尺寸**: 512x768（竖屏适合人像）
- **步数**: 30（平衡质量和速度）
- **引导**: 7.5（标准值）

### 风格说明

当前使用txt2img（文生图），特点：
- ✅ 完全免费
- ✅ 效果好
- ⚠️ 不会完美保留原图面部特征
- ⚠️ 更像"按描述生成"

如需完美保留人脸（InstantID），需要：
1. 部署SD WebUI到GPU服务器
2. 安装InstantID插件
3. 成本约￥1000/月（或使用AutoDL按需）

**建议**：
- 初期使用免费API（方案本文件）
- 用户多了再升级

---

## 🐛 常见问题

### Q1: 安装依赖失败？
```bash
# 清理缓存重试
rm -rf node_modules
npm cache clean --force
npm install
```

### Q2: 端口被占用？
```bash
# 查找占用进程
lsof -i :3001

# 杀死进程
kill -9 [PID]

# 或修改端口
export PORT=3002
npm start
```

### Q3: API请求失败？
- 检查防火墙是否开放3001端口
- 检查服务器安全组规则
- 查看日志：`pm2 logs zhaoxiangguan`

### Q4: 生成速度慢？
- 正常情况，免费API需要10-30秒
- 可以降低num_inference_steps到20（会降低质量）
- 可以切换到付费API或GPU服务器

---

## 📈 监控和日志

### 查看日志
```bash
# 实时日志
pm2 logs zhaoxiangguan

# 查看最近100行
pm2 logs zhaoxiangguan --lines 100

# 清空日志
pm2 flush zhaoxiangguan
```

### 监控状态
```bash
# 查看状态
pm2 status

# 重启
pm2 restart zhaoxiangguan

# 停止
pm2 stop zhaoxiangguan

# 删除
pm2 delete zhaoxiangguan
```

---

## 🎯 完成后检查清单

- [ ] 服务器成功部署
- [ ] API可访问：http://your-ip:3001/api/health
- [ ] 防火墙已开放3001端口
- [ ] Flutter应用已修改API地址
- [ ] APK构建成功
- [ ] 在手机上安装测试
- [ ] 测试完整流程（注册→上传→生成→下载）
- [ ] 准备应用图标
- [ ] 准备应用截图
- [ ] 提交应用商店

---

## 📞 需要帮助？

如果遇到问题，请检查：
1. 服务器日志：`pm2 logs zhaoxiangguan`
2. 防火墙设置
3. API地址配置
4. 网络连接

大部分问题都可以通过查看日志找到原因！

---

## 💡 下一步优化建议

### 阶段1：上线（当前）
- ✅ 使用免费Hugging Face API
- ✅ 单服务器部署
- ✅ 基础功能

### 阶段2：用户增长
- 添加队列系统
- 添加图片缓存
- 添加生成历史
- 添加水印（推广）

### 阶段3：规模化
- 升级到GPU服务器
- 部署InstantID（完美换脸）
- 负载均衡
- CDN加速

### 阶段4：商业化
- 考虑付费功能
- 高级风格
- 优先生成
- 去除广告

---

**祝您部署顺利！🚀**
