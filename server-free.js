const express = require('express');
const fetch = require('node-fetch');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3001;

// Hugging Face Inference API（免费）
const HF_API_URL = 'https://api-inference.huggingface.co/models';
const HF_MODEL = 'stable-diffusion-xl/latent-diffusion-xl-base-1.0';

app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// 静态文件
app.use('/uploads', express.static('uploads'));

// CORS
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
  next();
});

// 健康检查
app.get('/api/health', (req, res) => {
  res.json({
    success: true,
    message: 'Server is running',
    model: 'Stable Diffusion XL (Free API)',
    timestamp: new Date().toISOString()
  });
});

// 用户注册（简化）
app.post('/api/register', (req, res) => {
  const { phone, password } = req.body;
  res.json({
    success: true,
    message: '注册成功',
    data: {
      userId: `user_${Date.now()}`,
      phone: phone,
      points: 999999 // 免费版
    }
  });
});

// 用户登录
app.post('/api/login', (req, res) => {
  const { phone, password } = req.body;
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

// 图片生成接口（使用Hugging Face免费API）
app.post('/api/generate', async (req, res) => {
  try {
    const { image, style, substyle, userId } = req.body;

    if (!image || !style) {
      return res.status(400).json({
        success: false,
        message: '请上传照片并选择风格'
      });
    }

    console.log(`[${new Date().toISOString()}] 生成请求: ${style} - ${substyle}`);

    // 生成prompt
    const prompt = generatePrompt(style, substyle);
    const negativePrompt = 'low quality, blurry, distorted, ugly, bad anatomy, deformed';

    // 使用img2img（保持人脸特征）
    // 注意：HF免费API主要支持txt2img，所以我们用prompt来控制风格
    const fullPrompt = `${prompt}, portrait of a person, high quality, detailed`;

    // 调用Hugging Face API
    const response = await fetch(
      `${HF_API_URL}/${HF_MODEL}`,
      {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${process.env.HF_API_KEY || ''}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          inputs: fullPrompt,
          parameters: {
            negative_prompt: negativePrompt,
            num_inference_steps: 30,
            guidance_scale: 7.5,
            width: 512,
            height: 768
          }
        })
      }
    );

    if (!response.ok) {
      const errorText = await response.text();
      console.error('HF API错误:', response.status, errorText);
      throw new Error(`API错误: ${response.status} ${response.statusText}`);
    }

    // 获取图片（直接是二进制）
    const buffer = await response.buffer();

    // 保存图片
    const filename = `${userId || 'guest'}_${Date.now()}.png`;
    const uploadDir = path.join(__dirname, 'uploads');

    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }

    const imagePath = path.join(uploadDir, filename);
    fs.writeFileSync(imagePath, buffer);

    // 获取服务器IP
    const serverIp = req.headers.host?.split(':')[0] || 'localhost';

    console.log(`✅ 生成成功: ${filename}`);

    res.json({
      success: true,
      imageUrl: `http://${serverIp}:${PORT}/uploads/${filename}`,
      filename: filename
    });

  } catch (error) {
    console.error('生成错误:', error);
    res.status(500).json({
      success: false,
      message: error.message || '生成失败，请稍后重试'
    });
  }
});

// 生成prompt
function generatePrompt(style, substyle) {
  const prompts = {
    '写真': {
      '日系清新': 'soft natural lighting, japanese photography style, gentle, fresh, delicate features, beautiful',
      '欧美时尚': 'fashion photography, western style, professional lighting, high fashion, sharp, stylish',
      '性感风': 'attractive, confident, stylish, dramatic lighting, alluring, glamorous',
      '学院风': 'youthful, school style, cute, fresh, young, innocent',
      '甜美风': 'sweet, lovely, soft colors, innocent, adorable, charming',
    },
    '艺术': {
      '时尚杂志': 'magazine cover style, professional photography, editorial, high fashion, polished',
      '情节艺术': 'cinematic, storytelling, dramatic scene, artistic, emotional',
      '抽象艺术': 'artistic interpretation, abstract elements, creative, unique, artistic',
      '油画风': 'oil painting style, classical art, masterpiece, detailed, brush strokes',
    },
    '古风': {
      '唐朝': 'tang dynasty style, ancient chinese costume, palace, elegant, royal, ornate',
      '宋朝': 'song dynasty style, ancient chinese, scholarly, refined, graceful',
      '明朝': 'ming dynasty style, ancient chinese, royal, ornate, majestic',
      '魏晋': 'wei jin dynasty style, ancient chinese scholar, elegant, free-spirited',
      '汉服': 'traditional chinese hanfu, elegant, classical, beautiful, graceful',
    },
    '复古': {
      '港风': '1980s hong kong style, vintage photography, retro, nostalgic, classic',
      '民国': '1920s shanghai style, vintage chinese, nostalgic, elegant',
      '胶片': 'film photography style, grainy, vintage colors, retro, classic',
      '黑白复古': 'black and white photography, classic, timeless, monochrome',
    },
    '婚纱': {
      '室内主纱': 'wedding photography, white wedding dress, elegant, romantic, bridal',
      '清新森系': 'wedding photography, outdoor, forest, natural, fresh, ethereal',
      '中式': 'traditional chinese wedding, red dress, ceremonial, cultural',
      '浪漫夜景': 'wedding photography, night scene, romantic lighting, dreamy',
      '海边漫步': 'beach wedding, ocean, natural light, romantic, seaside',
    },
    '证件': {
      '一寸': 'id photo, plain background, professional lighting, front view, clear, formal',
      '二寸': 'id photo, plain background, professional lighting, front view, formal',
      '小二寸': 'passport photo, plain background, professional, clear, formal',
      '五寸': 'large photo, professional quality, detailed, sharp',
    },
  };

  const stylePrompts = prompts[style] || prompts['写真'];
  return stylePrompts[substyle] || stylePrompts['日系清新'];
}

// 根路径
app.get('/', (req, res) => {
  res.send(`
    <html>
      <head>
        <title>造像馆 API</title>
        <meta charset="utf-8">
        <style>
          body { font-family: Arial; max-width: 800px; margin: 50px auto; padding: 20px; }
          h1 { color: #007AFF; }
          .status { background: #f0f0f0; padding: 10px; border-radius: 5px; }
        </style>
      </head>
      <body>
        <h1>🎨 造像馆 API 服务</h1>
        <div class="status">
          <p><strong>状态:</strong> ✅ 运行中</p>
          <p><strong>模型:</strong> Stable Diffusion XL (Hugging Face免费API)</p>
          <p><strong>模式:</strong> 完全免费</p>
        </div>
        <h2>API端点:</h2>
        <ul>
          <li>GET /api/health - 健康检查</li>
          <li>POST /api/register - 用户注册</li>
          <li>POST /api/login - 用户登录</li>
          <li>POST /api/generate - 生成图片</li>
        </ul>
        <p>🚀 服务已就绪，可以接收请求！</p>
      </body>
    </html>
  `);
});

// 启动服务器
app.listen(PORT, () => {
  console.log('');
  console.log('╔════════════════════════════════════════╗');
  console.log('║   🎨 造像馆 API 服务                    ║');
  console.log('╚════════════════════════════════════════╝');
  console.log('');
  console.log(`✅ 服务器已启动`);
  console.log(`🌐 地址: http://localhost:${PORT}`);
  console.log(`📡 API: http://localhost:${PORT}/api`);
  console.log(`🤖 模型: Stable Diffusion XL`);
  console.log(`💰 费用: 完全免费`);
  console.log('');
  console.log('等待请求...');
  console.log('');
});

// 优雅退出
process.on('SIGINT', () => {
  console.log('\n👋 服务器已关闭');
  process.exit(0);
});
