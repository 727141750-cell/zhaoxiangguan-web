# Stable Diffusion 免费图片生成部署指南

## 为什么选择 Stable Diffusion？

### ✅ 优势
1. **完全免费** - 本地部署，无API调用费用
2. **无限使用** - 无次数限制
3. **高质量输出** - 图片质量优秀
4. **支持InstantID** - 只需一张自拍照即可换脸
5. **开源可定制** - 完全控制，可自定义风格
6. **隐私安全** - 图片不经过第三方服务器

### 与Replicate对比

| 特性 | Replicate（当前） | Stable Diffusion（推荐） |
|------|------------------|------------------------|
| 费用 | 按次收费 💰 | 完全免费 ✅ |
| 使用次数 | 有限制 | 无限制 ✅ |
| 自拍效果 | 好 | 更好 ✅ |
| 隐私 | 经过第三方 | 完全本地 ✅ |
| 部署难度 | 简单 | 中等 |
| 服务器成本 | API费用 | 仅服务器成本 ✅ |

---

## 部署方案选择

### 方案1：本地部署（开发测试）

**优点**：零成本，快速开始
**缺点**：无法提供给远程用户使用
**适用**：开发和测试阶段

**硬件要求**：
- GPU: NVIDIA RTX 3060 (12GB VRAM) 或更好
- RAM: 16GB+
- 存储: 50GB+ SSD

### 方案2：云服务器部署（推荐生产）⭐

**优点**：可远程访问，可扩展
**缺点**：需要服务器费用
**适用**：正式上线

**推荐配置**：
- GPU: NVIDIA Tesla T4 (16GB) 或 A10G (24GB)
- RAM: 32GB+
- 存储: 100GB+ SSD
- 预估成本：￥500-1500/月

**云平台选择**：
1. **阿里云** - PAI-EAS
2. **腾讯云** - GPU云服务器
3. **AutoDL** - 性价比高（推荐）
4. **Google Colab Pro** - 临时方案

---

## 部署步骤（详细）

### 第一步：安装Stable Diffusion WebUI

#### 选项A：使用AUTOMATIC1111（最流行）

```bash
# 克隆仓库
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui
cd stable-diffusion-webui

# Windows用户直接运行
webui-user.bat

# Linux/Mac用户
./webui-user.sh
```

#### 选项B：使用ComfyUI（更现代，推荐）

```bash
# 克隆仓库
git clone https://github.com/comfyanonymous/ComfyUI
cd ComfyUI

# 安装依赖
pip install -r requirements.txt

# 启动
python main.py --listen 0.0.0.0 --port 8188
```

### 第二步：安装InstantID插件

InstantID是专门用于自拍照换脸的插件，效果非常好。

```bash
# 进入ComfyUI的custom_nodes目录
cd ComfyUI/custom_nodes

# 克隆InstantID插件
git clone https://github.com/Zovence/ComfyUI_InstantID
```

或者下载预训练模型：
```bash
# 下载InstantID模型到models/instantid
# ControlNet模型
wget https://huggingface.co/InstantX/InstantID/resolve/main/ControlNetModel.pth

# Face Adapter
wget https://huggingface.co/InstantX/InstantID/resolve/main/ipadapter.bin
```

### 第三步：配置API访问

#### AUTOMATIC1111 启用API

启动时添加参数：
```bash
./webui-user.sh --api --listen --port 7860
```

或修改`webui-user.sh`：
```bash
export COMMANDLINE_ARGS="--api --listen --port 7860"
```

#### ComfyUI 启用API

ComfyUI默认启用API，访问：
- Web界面: http://localhost:8188
- API文档: http://localhost:8188/prompt

### 第四步：测试API

#### 测试AUTOMATIC1111 API

```bash
# 获取模型列表
curl http://localhost:7860/sdapi/v1/sd-models

# 生成图片
curl http://localhost:7860/sdapi/v1/txt2img \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "a photo of a person",
    "steps": 20
  }'
```

#### 测试ComfyUI API

ComfyUI使用工作流JSON格式，需要：
1. 在Web界面创建工作流
2. 保存为API格式
3. 发送POST请求

---

## 修改后端代码对接Stable Diffusion

### 创建新的API服务文件

创建 `server-sd.js`：

```javascript
const express = require('express');
const fetch = require('node-fetch');
const FormData = require('form-data');
const fs = require('fs');

const app = express();
const PORT = 3001;

// Stable Diffusion WebUI配置
const SD_API_URL = process.env.SD_API_URL || 'http://localhost:7860';
const SD_API_KEY = process.env.SD_API_KEY || '';

// 中间件
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// 健康检查
app.get('/api/health', (req, res) => {
  res.json({
    success: true,
    message: 'Server is running',
    sdApiUrl: SD_API_URL
  });
});

// 图片生成接口（使用InstantID）
app.post('/api/generate', async (req, res) => {
  try {
    const { image, style, substyle } = req.body;

    if (!image || !style) {
      return res.status(400).json({
        success: false,
        message: '参数不完整'
      });
    }

    // 将base64图片转换为文件
    const buffer = Buffer.from(image, 'base64');
    const tempImagePath = `/tmp/input_${Date.now()}.png`;
    fs.writeFileSync(tempImagePath, buffer);

    // 根据风格生成prompt
    const prompt = generatePrompt(style, substyle);

    // 调用Stable Diffusion API
    const formData = new FormData();
    formData.append('init_images', buffer);
    formData.append('prompt', prompt);
    formData.append('denoising_strength', '0.75');
    formData.append('steps', '30');
    formData.append('cfg_scale', '7.5');
    formData.append('width', '512');
    formData.append('height', '768');

    const response = await fetch(`${SD_API_URL}/sdapi/v1/img2img`, {
      method: 'POST',
      body: formData,
      headers: formData.getHeaders()
    });

    const result = await response.json();

    if (result.images && result.images.length > 0) {
      // 保存生成的图片
      const outputImage = result.images[0];
      const outputPath = `/uploads/${Date.now()}.png`;
      fs.writeFileSync(`./public${outputPath}`, Buffer.from(outputImage, 'base64'));

      // 清理临时文件
      fs.unlinkSync(tempImagePath);

      res.json({
        success: true,
        imageUrl: `http://your-domain.com${outputPath}`
      });
    } else {
      res.status(500).json({
        success: false,
        message: '生成失败'
      });
    }
  } catch (error) {
    console.error('生成错误:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// 根据风格生成prompt
function generatePrompt(style, substyle) {
  const prompts = {
    '写真': {
      '日系清新': 'portrait, soft lighting, japanese photography style, natural skin, outdoor, high quality',
      '欧美时尚': 'portrait, fashion photography, western style, professional lighting, high fashion',
      '性感风': 'portrait, attractive, confident, stylish, dramatic lighting',
      '学院风': 'portrait, youthful, school uniform style, cute, fresh',
      '甜美风': 'portrait, sweet, lovely, soft colors, innocent look',
    },
    '艺术': {
      '时尚杂志': 'portrait, magazine cover style, professional photography, high fashion',
      '情节艺术': 'portrait, cinematic, storytelling, dramatic scene',
      '抽象艺术': 'portrait, artistic interpretation, abstract elements, creative',
      '油画风': 'portrait, oil painting style, classical art, masterpiece',
    },
    '古风': {
      '唐朝': 'portrait, tang dynasty style, ancient chinese costume, palace background',
      '宋朝': 'portrait, song dynasty style, elegant ancient chinese, scholarly',
      '明朝': 'portrait, ming dynasty style, royal ancient chinese',
      '魏晋': 'portrait, wei jin dynasty style, ancient chinese scholar',
      '汉服': 'portrait, traditional chinese hanfu, elegant, classical',
    },
    '复古': {
      '港风': 'portrait, 1980s hong kong style, vintage photography, retro',
      '民国': 'portrait, 1920s shanghai style, vintage chinese, nostalgic',
      '胶片': 'portrait, film photography style, grainy, vintage colors',
      '黑白复古': 'portrait, black and white photography, classic, timeless',
    },
    '婚纱': {
      '室内主纱': 'portrait, wedding photography, white wedding dress, elegant',
      '清新森系': 'portrait, wedding photography, outdoor, forest, natural',
      '中式': 'portrait, traditional chinese wedding, red dress, ceremonial',
      '浪漫夜景': 'portrait, wedding photography, night scene, romantic lighting',
      '海边漫步': 'portrait, beach wedding, ocean, natural light, romantic',
    },
    '证件': {
      '一寸': 'portrait, id photo, plain background, professional lighting, front view',
      '二寸': 'portrait, id photo, plain background, professional lighting, front view',
      '小二寸': 'portrait, passport photo, plain background, professional',
      '五寸': 'portrait, large photo, professional quality',
    },
  };

  const stylePrompts = prompts[style] || prompts['写真'];
  return stylePrompts[substyle] || stylePrompts['日系清新'] + ', best quality, ultra detailed';
}

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`SD API URL: ${SD_API_URL}`);
});
```

### 修改Flutter应用

更新 `api_service.dart`：

```dart
class ApiService {
  static const String baseUrl = 'http://your-server-ip:3001';

  // 其他代码保持不变
}
```

---

## 部署到云服务器

### 使用AutoDL（推荐，性价比高）

1. **注册账号**
   - 访问 https://www.autodl.com
   - 注册并实名认证

2. **选择服务器**
   - 选择"社区镜像"
   - 搜索"Stable Diffusion"
   - 选择预装了SD WebUI的镜像
   - 推荐配置：RTX 3090 (24GB)

3. **启动实例**
   - 按小时计费，约￥1-2/小时
   - 选择"按量付费"模式

4. **启用API**
   - Jupyter终端运行：
   ```bash
   cd stable-diffusion-webui
   ./webui.sh --api --listen --port 7860
   ```

5. **获取外网地址**
   - AutoDL会提供外网端口映射
   - 记录API地址

### 使用阿里云PAI-EAS

1. **创建实例**
   - 登录阿里云控制台
   - 进入PAI-EAS
   - 创建"Stable Diffusion"服务

2. **配置**
   - 选择GPU类型
   - 设置实例数量
   - 配置端口映射

3. **部署**
   - 提交部署
   - 等待服务启动
   - 获取API地址

---

## 成本估算

### AutoDL（推荐）
- RTX 3090: ￥1.5/小时 ≈ ￥1080/月（24小时运行）
- RTX 4090: ￥2.5/小时 ≈ ￥1800/月

### 阿里云PAI-EAS
- 按需计费：约￥2-4/小时
- 包月：约￥3000-5000/月

### 自建服务器
- GPU服务器采购：￥15000-30000
- 电费（24小时运行）：￥300-500/月
- 维护成本：低

**建议**：初期使用AutoDL按量付费，用户量稳定后再考虑自建或包月。

---

## 性能优化

### 1. 使用图片缓存
相同风格+人脸组合缓存结果，避免重复生成

### 2. 使用队列系统
- 用户提交生成请求
- 加入队列
- 按顺序生成
- 生成完成后通知用户

### 3. 调整参数
- 降低分辨率（512x768足够）
- 减少steps（20-30步）
- 批量生成时使用更激进的参数

---

## 下一步行动

### 立即行动
1. ✅ 修改后端代码，删除积分和支付
2. ⏳ 本地测试Stable Diffusion
3. ⏳ 在AutoDL租用GPU服务器
4. ⏳ 部署SD WebUI + InstantID
5. ⏳ 修改后端API对接SD
6. ⏳ 测试完整流程

### 测试清单
- [ ] 上传自拍照
- [ ] 选择风格
- [ ] 生成图片
- [ ] 下载图片
- [ ] 验证质量

---

## 常见问题

### Q1: 生成速度慢？
A: 正常情况，一张图片需要10-30秒。可以：
- 使用更好的GPU（4090比3090快50%）
- 降低分辨率
- 减少steps

### Q2: 效果不好？
A: 可以：
- 调整prompt
- 尝试不同LoRA
- 使用更好的controlnet模型
- 提高输入照片质量

### Q3: 成本太高？
A: 可以：
- 使用AutoDL按量付费
- 非高峰时段关闭服务器
- 多用户共享一个GPU
- 使用队列系统提高利用率

---

## 参考资料

- [Stable Diffusion WebUI GitHub](https://github.com/AUTOMATIC1111/stable-diffusion-webui)
- [ComfyUI GitHub](https://github.com/comfyanonymous/ComfyUI)
- [InstantID GitHub](https://github.com/InstantID/InstantID)
- [AutoDL官网](https://www.autodl.com)
- [阿里云PAI-EAS](https://www.aliyun.com/product/pai)

---

Sources:
- [2025最新Stable Diffusion完全指南](https://www.cursor-ide.com/blog/stable-diffusion-guide-2025)
- [Stable Diffusion InstantID炸裂！只需要一张图就可以换脸](https://www.shejidaren.com/stable-diffusion-instantid.html)
- [2024最新换脸技术盘点，InstantID封神](https://zhuanlan.zhihu.com/p/684363849)
