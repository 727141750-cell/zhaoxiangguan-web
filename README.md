# 造像馆 iOS APP

一款基于SwiftUI开发的AI艺术照生成iOS应用，可以将自拍转化为10种不同风格的艺术照片。

## 功能特性

### 核心功能
- **拍照/上传** - 支持相机拍摄和相册选择
- **10种艺术风格** - 欧式油画、清新水彩、国潮水墨、动漫二次元、复古胶片、海边落日、雪山之巅、樱花秘境、古城巷陌、森系治愈
- **AI生成** - 一键生成艺术大片
- **重新生成** - 不满意可随时重新生成
- **无水印下载** - 积分制下载高清无水印图片

### 用户系统
- 手机号验证码登录
- 微信/Apple ID 第三方登录
- 用户信息管理

### 积分系统
- 注册赠送100积分
- 三档充值套餐
- 充值记录查询
- 每张图片消耗100积分

### 下载管理
- 自定义相册保存
- 下载历史记录
- 图片分享功能

## 技术栈

- **语言**: Swift 5.0+
- **UI框架**: SwiftUI
- **最低版本**: iOS 17.0+
- **架构**: MVVM

## 项目结构

```
ZhaoXiangGuan/
├── ZhaoXiangGuanApp.swift       # APP入口
├── Models/                       # 数据模型
│   ├── UserSession.swift         # 用户会话
│   ├── PointsManager.swift       # 积分管理
│   └── ArtStyle.swift            # 艺术风格枚举
├── Views/                        # 视图
│   ├── ContentView.swift         # 主Tab视图
│   ├── HomeView.swift            # 首页
│   ├── StyleSelectionView.swift  # 风格选择
│   ├── GenerationResultView.swift # 生成结果
│   ├── MyView.swift              # 个人中心
│   ├── LoginView.swift           # 登录注册
│   ├── RechargeView.swift        # 充值页面
│   └── ...
├── Services/                     # 服务层
│   └── APIService.swift          # API服务
└── Utils/                        # 工具类
    ├── ImageProcessor.swift      # 图片处理
    └── DownloadManager.swift     # 下载管理
```

## 开发环境配置

### 必要条件
1. macOS 14.0+
2. Xcode 15.0+
3. iOS 17.0+ 设备或模拟器

### 安装步骤

1. 克隆项目到本地
```bash
git clone <repository-url>
cd zhaoxiangguan
```

2. 使用Xcode打开项目
```bash
open ZhaoXiangGuan.xcodeproj
```

3. 配置开发团队
- 在Xcode中选择项目
- 在 "Signing & Capabilities" 中选择你的开发团队
- Xcode会自动生成Bundle Identifier和配置文件

4. 配置API地址
- 在 `APIService.swift` 中修改 `APIConfig.baseURL` 为实际的后端API地址

5. 运行项目
- 选择目标设备（模拟器或真机）
- 点击运行按钮或按 `Cmd+R`

## API接口说明

### 认证相关
- `POST /api/v1/auth/code` - 发送验证码
- `POST /api/v1/auth/phone` - 手机号登录
- `POST /api/v1/auth/third-party` - 第三方登录

### 图片生成
- `POST /api/v1/generate` - 生成艺术照
- `POST /api/v1/regenerate` - 重新生成

### 积分相关
- `GET /api/v1/points` - 获取积分余额
- `POST /api/v1/orders` - 创建充值订单
- `GET /api/v1/orders/:id/status` - 查询订单状态

## 权限配置

在 `Info.plist` 中已配置以下权限说明：

- **相机权限**: "需要相机权限，以便你拍摄自拍"
- **相册权限**: "需要相册权限，以便你保存无水印艺术照"

## 注意事项

1. **图片处理**: 当前使用CoreImage滤镜模拟风格效果，生产环境需要接入真实的AI生成API

2. **支付功能**: 充值功能目前是模拟的，实际使用需要集成：
   - 微信支付 SDK
   - 支付宝 SDK
   - Apple Pay (StoreKit)

3. **第三方登录**: 需要配置相应的开发者账号和App ID

4. **图片存储**: 建议使用CDN存储生成的图片，减轻服务器压力

5. **隐私合规**: 上架App Store前请确保：
   - 完善隐私政策
   - 添加用户协议
   - 做好数据加密
   - 符合App Store审核指南

## 后续优化方向

- [ ] 接入真实AI模型
- [ ] 添加更多风格
- [ ] 支持视频生成
- [ ] 优化图片压缩算法
- [ ] 添加社交分享功能
- [ ] 会员体系
- [ ] 推送通知

## 联系方式

如有问题或建议，请联系开发团队。

## 许可证

Copyright © 2025 造像馆. All rights reserved.
