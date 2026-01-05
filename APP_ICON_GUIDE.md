# 造像馆应用图标设计指南

## 应用图标要求

### Android
- **Play Store图标**: 512 x 512 px (PNG)
- **自适应图标前景**: 512 x 512 px (PNG, 无透明区域)
- **自适应图标背景**: 512 x 512 px (PNG或颜色)
- **通知图标**: 24 x 24 px (白色透明PNG)

### 应用商店所需尺寸
1. **Google Play**
   - 应用图标: 512 x 512 px
   - 特效图: 1024 x 500 px

2. **华为应用市场**
   - 应用图标: 512 x 512 px
   - 截图: 至少2张

3. **小米应用商店**
   - 应用图标: 512 x 512 px
   - 截图: 至少3张

## 设计建议

### 主题
- **核心理念**: AI艺术照生成
- **视觉元素**: 相机镜头、艺术画笔、魔法棒
- **风格**: 现代简约、科技感

### 配色方案
- **主色**: #007AFF (蓝色) - 代表科技
- **辅色**: #5AC8FA (浅蓝) - 渐变效果
- **强调色**: #FFD700 (金色) - 代表高质量

### 设计概念

#### 方案1：相机+艺术
- 主体：简约相机轮廓
- 背景：渐变蓝色
- 细节：相机镜头内含画笔图标
- 寓意：用相机创造艺术

#### 方案2：魔法镜头
- 主体：魔法棒+镜头组合
- 背景：深色科技感
- 细节：星光点缀
- 寓意：AI魔法转换

#### 方案3：人像艺术
- 主体：抽象人像轮廓
- 背景：多彩渐变
- 细节：6种风格的小图标环绕
- 寓意：多种风格选择

### 图标文件位置
```
com_zhaoxiangguan_app/android/app/src/main/res/
├── mipmap-hdpi/
│   ├── ic_launcher.png (72x72)
│   └── ic_launcher_round.png (72x72)
├── mipmap-mdpi/
│   ├── ic_launcher.png (48x48)
│   └── ic_launcher_round.png (48x48)
├── mipmap-xhdpi/
│   ├── ic_launcher.png (96x96)
│   └── ic_launcher_round.png (96x96)
├── mipmap-xxhdpi/
│   ├── ic_launcher.png (144x144)
│   └── ic_launcher_round.png (144x144)
└── mipmap-xxxhdpi/
    ├── ic_launcher.png (192x192)
    └── ic_launcher_round.png (192x192)
```

### 使用工具生成图标

推荐使用以下工具生成完整的应用图标包：

1. **Android Studio**
   - 右键点击res文件夹 → Image Asset
   - 选择源图片（512x512）
   - 自动生成所有尺寸

2. **在线工具**
   - https://easyappicon.com/
   - https://appicon.co/
   - 上传512x512图标，下载完整包

3. **命令行工具**
   ```bash
   # 使用ImageMagick批量生成
   convert icon-512.png -resize 72x72 mipmap-hdpi/ic_launcher.png
   convert icon-512.png -resize 96x96 mipmap-xhdpi/ic_launcher.png
   # ... 其他尺寸
   ```

## 设计交付物

### 设计师需要提供：
1. **源文件**: PSD/AI/SVG格式
2. **主图标**: 1024 x 1024 px (PNG)
3. **自适应图标**:
   - 前景图层: 512 x 512 px
   - 背景图层: 512 x 512 px 或颜色值
4. **Play Store图标**: 512 x 512 px (安全区域: 中心384x384)

### 图标规范检查清单
- [ ] 图标无文字（应用名称会自动显示）
- [ ] 视觉清晰，在小尺寸下可识别
- [ ] 符合Android Material Design指南
- [ ] 背景不透明
- [ ] 无透明边缘或光晕
- [ ] 在浅色和深色背景下都清晰可见
- [ ] 不使用版权保护的图片或logo
- [ ] 不包含截图或其他应用界面

## 下一步行动

1. ✅ 代码已准备就绪
2. ⏳ 等待设计师创建图标
3. ⏳ 替换默认图标
4. ⏳ 构建最终APK
5. ⏳ 准备商店截图

## 临时解决方案

如果暂时没有专业设计师，可以：

1. **使用Canva/Figma等在线设计工具**
   - 搜索"camera app icon"模板
   - 修改颜色和文字
   - 导出512x512 PNG

2. **使用AI生成工具**
   - Midjourney/DALL-E生成
   - 提示词: "modern camera app icon, minimal design, blue gradient, white background, vector style"

3. **简化版图标**
   - 使用纯色背景+白色相机图标
   - 简单但专业
