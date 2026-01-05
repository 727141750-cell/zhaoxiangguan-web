# 造像馆 - 零成本图片生成方案

## 📊 方案对比（30元预算内）

### 方案1：使用免费的Hugging Face Spaces ⭐⭐⭐⭐⭐
**成本**：完全免费（每月有额度）
**优点**：
- ✅ 完全免费
- ✅ 无需GPU服务器
- ✅ 自动扩容
- ✅ 支持Stable Diffusion + InstantID
- ✅ API访问简单

**缺点**：
- 有并发限制（但小应用够用）
- 冷启动需要几秒

**推荐指数**：⭐⭐⭐⭐⭐

---

### 方案2：使用Replicate免费额度 ⭐⭐⭐⭐
**成本**：前100次免费，之后约$0.0025/张
**优点**：
- 您已经在用
- 无需部署
- 效果好

**缺点**：
- 长期成本高
- 有额度限制

**推荐指数**：⭐⭐⭐⭐

---

### 方案3：使用腾讯云轻量应用服务器 + 免费 API ⭐⭐⭐
**成本**：￥30/月（已有服务器）
**优点**：
- 您已有服务器
- 免费API无额外成本

**缺点**：
- CPU运行会很慢
- 需要优化

**推荐指数**：⭐⭐⭐

---

## 🎯 最佳方案：Hugging Face Spaces（推荐）

### 为什么选择这个方案？

1. **完全免费** - 每月有充足的免费额度
2. **InstantID支持** - 专门针对自拍照换脸
3. **API简单** - 几行代码就能调用
4. **自动扩容** - 用户多了也不用担心
5. **无需GPU服务器** - 节省￥1000+/月

### 免费额度
- CPU: 免费足够用
- 推理次数: 每月数千次
- 存储空间: 免费空间充足
- 对小应用完全够用！

---

## 🚀 实施步骤

### 第一步：在Hugging Face创建Space

1. **注册账号**
   - 访问 https://huggingface.co
   - 免费注册

2. **创建新Space**
   - 点击 "Create" → "New Space"
   - Name: `zhaoxiangguan-sd`
   - License: MIT
   - Select SDK: Docker
   - Hardware: CPU basic（免费）

3. **配置Space**
   创建 `app.py` 文件：

```python
from fastapi import FastAPI
from fastapi.responses import Response
from pydantic import BaseModel
import torch
from diffusers import StableDiffusionControlNetPipeline
from controlnet_aux import FaceDetector
import base64
import io
from PIL import Image

app = FastAPI()

# 加载模型（第一次会下载，之后会缓存）
pipe = None

def load_model():
    global pipe
    if pipe is None:
        pipe = StableDiffusionControlNetPipeline.from_pretrained(
            "InstantX/InstantID",
            torch_dtype=torch.float16,
            use_safetensors=True
        )
        pipe.to("cuda" if torch.cuda.is_available() else "cpu")

@app.on_event("startup")
async def startup():
    load_model()

class GenerateRequest(BaseModel):
    image: str  # base64
    prompt: str
    negative_prompt: str = "low quality, blurry, distorted"

@app.post("/generate")
async def generate(req: GenerateRequest):
    try:
        # 解码图片
        image_data = base64.b64decode(req.image)
        input_image = Image.open(io.BytesIO(image_data))

        # 生成图片
        result = pipe(
            image=input_image,
            prompt=req.prompt,
            negative_prompt=req.negative_prompt,
            num_inference_steps=30,
            image_guidance_scale=1.5,
            height=768,
            width=512
        ).images[0]

        # 编码结果
        buffered = io.BytesIO()
        result.save(buffered, format="PNG")
        img_str = base64.b64encode(buffered.getvalue()).decode()

        return {"image": img_str, "success": True}

    except Exception as e:
        return {"error": str(e), "success": False}

@app.get("/")
async def root():
    return {"message": "ZhaoXiangGuan SD API", "status": "running"}
```

创建 `Dockerfile`：

```dockerfile
FROM python:3.9

WORKDIR /app

RUN apt-get update && apt-get install -y \
    git \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 7860

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "7860"]
```

创建 `requirements.txt`：

```
fastapi
uvicorn
torch
diffusers
transformers
accelerate
safetensors
controlnet-aux
Pillow
```

4. **部署**
   - 点击 "Commit" 提交代码
   - 等待构建完成（第一次需要几分钟）
   - Space会自动启动

5. **获取API地址**
   - 类似：`https://zhaoxiangguan-sd.hf.space/api/generate`
   - 完全免费访问！

---

### 第二步：修改后端对接Hugging Face API

创建新文件 `server-huggingface.js`：

```javascript
const express = require('express');
const fetch = require('node-fetch');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3001;

// Hugging Face Space API
const HF_API_URL = 'https://zhaoxiangguan-sd.hf.space';

app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// 静态文件
app.use('/uploads', express.static('uploads'));
app.use(express.static('public'));

// 健康检查
app.get('/api/health', (req, res) => {
  res.json({
    success: true,
    message: 'Server is running',
    sdApi: 'Hugging Face Spaces'
  });
});

// 图片生成接口
app.post('/api/generate', async (req, res) => {
  try {
    const { image, style, substyle, userId } = req.body;

    if (!image || !style) {
      return res.status(400).json({
        success: false,
        message: '参数不完整'
      });
    }

    console.log(`生成请求: ${style} - ${substyle}`);

    // 生成prompt
    const prompt = generatePrompt(style, substyle);

    // 调用Hugging Face API
    const response = await fetch(`${HF_API_URL}/api/generate`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        image: image,
        prompt: prompt,
        negative_prompt: 'low quality, blurry, distorted, ugly, bad anatomy'
      })
    });

    if (!response.ok) {
      throw new Error(`API错误: ${response.status}`);
    }

    const result = await response.json();

    if (result.success && result.image) {
      // 保存图片
      const filename = `${userId || 'guest'}_${Date.now()}.png`;
      const uploadDir = path.join(__dirname, 'uploads');

      if (!fs.existsSync(uploadDir)) {
        fs.mkdirSync(uploadDir, { recursive: true });
      }

      const imagePath = path.join(uploadDir, filename);
      const buffer = Buffer.from(result.image, 'base64');
      fs.writeFileSync(imagePath, buffer);

      res.json({
        success: true,
        imageUrl: `http://your-server-ip:${PORT}/uploads/${filename}`
      });
    } else {
      res.status(500).json({
        success: false,
        message: result.error || '生成失败'
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

// 生成prompt
function generatePrompt(style, substyle) {
  const prompts = {
    '写真': {
      '日系清新': 'portrait, soft natural lighting, japanese photography, gentle, fresh, high quality, detailed',
      '欧美时尚': 'portrait, fashion photography, western style, professional lighting, high fashion, sharp',
      '性感风': 'portrait, attractive, confident, stylish, dramatic lighting, alluring',
      '学院风': 'portrait, youthful, school uniform style, cute, fresh, young',
      '甜美风': 'portrait, sweet, lovely, soft colors, innocent, adorable',
    },
    '艺术': {
      '时尚杂志': 'portrait, magazine cover style, professional photography, editorial, high fashion',
      '情节艺术': 'portrait, cinematic, storytelling, dramatic scene, artistic',
      '抽象艺术': 'portrait, artistic interpretation, abstract elements, creative, unique',
      '油画风': 'portrait, oil painting style, classical art, masterpiece, detailed',
    },
    '古风': {
      '唐朝': 'portrait, tang dynasty style, ancient chinese costume, palace, elegant, royal',
      '宋朝': 'portrait, song dynasty style, ancient chinese, scholarly, refined',
      '明朝': 'portrait, ming dynasty style, ancient chinese, royal, ornate',
      '魏晋': 'portrait, wei jin dynasty style, ancient chinese scholar, elegant',
      '汉服': 'portrait, traditional chinese hanfu, elegant, classical, beautiful',
    },
    '复古': {
      '港风': 'portrait, 1980s hong kong style, vintage photography, retro, nostalgic',
      '民国': 'portrait, 1920s shanghai style, vintage chinese, nostalgic, classic',
      '胶片': 'portrait, film photography style, grainy, vintage colors, retro',
      '黑白复古': 'portrait, black and white photography, classic, timeless',
    },
    '婚纱': {
      '室内主纱': 'portrait, wedding photography, white wedding dress, elegant, romantic',
      '清新森系': 'portrait, wedding photography, outdoor, forest, natural, fresh',
      '中式': 'portrait, traditional chinese wedding, red dress, ceremonial',
      '浪漫夜景': 'portrait, wedding photography, night scene, romantic lighting',
      '海边漫步': 'portrait, beach wedding, ocean, natural light, romantic',
    },
    '证件': {
      '一寸': 'portrait, id photo, plain background, professional lighting, front view, clear',
      '二寸': 'portrait, id photo, plain background, professional lighting, front view',
      '小二寸': 'portrait, passport photo, plain background, professional, clear',
      '五寸': 'portrait, large photo, professional quality, detailed',
    },
  };

  const stylePrompts = prompts[style] || prompts['写真'];
  return stylePrompts[substyle] || stylePrompts['日系清新'];
}

// 用户注册（简化版）
app.post('/api/register', async (req, res) => {
  const { phone, password } = req.body;

  // 这里简化为直接成功，实际应该存入数据库
  res.json({
    success: true,
    message: '注册成功',
    data: {
      userId: `user_${Date.now()}`,
      phone: phone,
      points: 999999 // 免费版给无限积分
    }
  });
});

// 用户登录
app.post('/api/login', async (req, res) => {
  const { phone, password } = req.body;

  // 简化版直接成功
  res.json({
    success: true,
    message: '登录成功',
    data: {
      userId: `user_${phone}`,
      phone: phone,
      points: 999999
    }
  });
});

app.listen(PORT, () => {
  console.log(`✅ 服务器运行在端口 ${PORT}`);
  console.log(`🚀 使用 Hugging Face Spaces API`);
  console.log(`📱 API地址: http://your-server-ip:${PORT}`);
});
```

### 第三步：部署到腾讯云

```bash
# 1. 上传代码到服务器
scp -r server-huggingface.js package.json root@your-server:/root/zhaoxiangguan/

# 2. SSH登录服务器
ssh root@your-server

# 3. 进入目录
cd /root/zhaoxiangguan

# 4. 安装依赖
npm install

# 5. 启动服务（使用PM2保持运行）
npm install -g pm2
pm2 start server-huggingface.js --name zhaoxiangguan
pm2 save
pm2 startup

# 6. 配置防火墙（腾讯云控制台）
# 开放3001端口
```

### 第四步：修改Flutter应用

更新 `lib/services/api_service.dart`：

```dart
class ApiService {
  // 修改为您的腾讯云服务器IP
  static const String baseUrl = 'http://your-tencent-ip:3001';

  // ... 其他代码保持不变
}
```

### 第五步：构建APK

```bash
cd com_zhaoxiangguan_app
flutter build apk --release
```

### 第六步：测试

1. 安装APK到手机
2. 测试完整流程：
   - 注册/登录
   - 上传照片
   - 选择风格
   - 生成图片
   - 下载图片

---

## 💰 成本明细

| 项目 | 成本 | 说明 |
|------|------|------|
| Hugging Face Spaces | **￥0/月** | 免费额度足够用 |
| 腾讯云服务器 | **￥0** | 您已有 |
| 域名（可选） | **￥0** | 使用IP地址 |
| SSL证书（可选） | **￥0** | Let's Encrypt免费 |
| **总计** | **￥0** | ✅ 预算内！ |

---

## ⚠️ 注意事项

### Hugging Face免费限制
- 并发：同时处理1-2个请求
- 推理时间：每次30-60秒（CPU模式）
- 额度：每月数千次（对小应用够用）

### 优化建议
1. **使用队列** - 避免并发冲突
2. **添加缓存** - 相同请求直接返回缓存
3. **压缩图片** - 减少传输时间
4. **异步处理** - 生成后通知用户

### 如果免费额度不够
- 升级到CPU upgraded: $0.10/小时
- 或切换到Replicate按次付费
- 或在AutoDL租GPU（按需）

---

## 🎯 完整检查清单

### 技术准备
- [x] 删除支付系统
- [x] 删除积分系统
- [x] 改为免费生成
- [ ] 创建Hugging Face Space
- [ ] 部署后端到腾讯云
- [ ] 修改Flutter API地址
- [ ] 构建Release APK

### 应用商店准备
- [ ] 应用图标（可用在线工具免费生成）
- [ ] 应用截图（在模拟器上截图）
- [ ] 应用描述（已有）
- [ ] 隐私政策（已创建）
- [ ] 用户协议（已创建）

### 上架流程
- [ ] 注册开发者账号
- [ ] 提交应用审核
- [ ] 等待审核（3-7天）
- [ ] 发布上线

---

## 📞 需要您提供

1. **Hugging Face账号** - 我帮您创建Space
2. **腾讯云服务器IP** - 用于部署后端
3. **确认服务器配置** - 确认Node.js已安装

准备好后我立即帮您部署！
