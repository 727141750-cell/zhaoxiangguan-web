# 造像馆 - APK构建指南

## 当前状态
APK正在后台构建中，首次构建需要下载Gradle和所有依赖，可能需要10-20分钟。

## 项目位置
E:\code\zhaoxiangguan\com_zhaoxiangguan_app

## 已完成的工作

### 1. 完整的Flutter应用代码
- **用户系统**: 注册、登录、登出
- **积分系统**: 注册赠送100积分，充值功能
- **图片生成**: 支持拍照/相册，6种AI风格
- **支付模拟**: 支付宝/微信支付界面（模拟）

### 2. Android配置
- 包名: com.zhaoxiangguan.app
- 最低版本: Android 5.0 (API 21)
- 目标版本: Android 14 (API 34)
- 权限: 相机、存储、网络

### 3. 后端服务
- 服务器: http://121.5.33.130:3001
- API集成: Replicate InstantID + SDXL

## 构建命令

### 发布版APK
```bash
cd com_zhaoxiangguan_app
flutter build apk --release
```

### 输出位置
```
build/app/outputs/flutter-apk/app-release.apk
```

## 测试APK
构建完成后，可以通过以下方式测试：

1. **USB安装**
   ```bash
   adb install build/app/outputs/flutter-apk/app-release.apk
   ```

2. **手动安装**
   - 将APK复制到手机
   - 在手机上点击安装

## 应用功能说明

### 核心功能
1. **首页**: 展示应用介绍和风格列表
2. **生成页**: 拍照/选择照片 → 选择风格 → 生成艺术照
3. **我的**: 用户信息、积分余额、充值

### 积分消耗
- 注册赠送: 100积分
- 每次生成: 100积分
- 充值套餐: 100/500/1000积分

### API接口
- 基础地址: http://121.5.33.130:3001
- /api/health - 健康检查
- /api/register - 注册
- /api/login - 登录
- /api/generate - 生成图片

## 应用商店上架准备

### 已准备
- ✅ 应用描述 (STORE_LISTING.md)
- ✅ 功能说明
- ✅ 关键词列表

### 待准备
- ⏳ 应用图标 (需要设计师)
- ⏳ 应用截图 (需要在设备上截图)
- ⏳ 隐私政策页面
- ⏳ 用户协议页面

## 上架清单

### Google Play
1. 开发者账号 ($25一次性)
2. 应用图标 (512x512 PNG)
3. 功能截图 (至少2张，最多8张)
4. 应用描述
5. 隐私政策URL
6. 内容评级问卷

### 国内应用市场
1. **华为应用市场**
   - 企业认证
   - 软件著作权

2. **小米应用商店**
   - 开发者认证
   - 应用测试

3. **应用宝（腾讯）**
   - 企业资质
   - 应用审核

## 常见问题

### Q: 构建失败怎么办？
A:
1. 清理缓存: `flutter clean`
2. 删除.gradle目录
3. 重新构建: `flutter build apk --release`

### Q: 如何修改API地址？
A: 编辑 `lib/services/api_service.dart`，修改 `baseUrl`

### Q: 如何更换应用图标？
A: 替换 `android/app/src/main/res/mipmap-*/ic_launcher.png`

### Q: 如何修改应用名称？
A: 编辑 `android/app/src/main/AndroidManifest.xml`，修改 `android:label`

## 下一步

1. 等待APK构建完成
2. 在真机上测试所有功能
3. 准备应用图标和截图
4. 创建隐私政策和用户协议页面
5. 注册开发者账号
6. 提交到应用商店

## 技术支持
- 项目位置: E:\code\zhaoxiangguan
- 服务器状态: http://121.5.33.130:3001/api/health
- 文档: PROJECT_STATUS.md, STORE_LISTING.md
