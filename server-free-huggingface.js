const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const fetch = require('node-fetch');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3001;

// 中间件
app.use(cors());
app.use(bodyParser.json({ limit: '50mb' }));
app.use(bodyParser.urlencoded({ limit: '50mb', extended: true }));
app.use(express.static('uploads'));

// 创建uploads目录
const uploadsDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

// ============================================================
// 🆕 完全免费的 Hugging Face Inference API
// ============================================================
// 使用Stable Diffusion XL，每月免费数千次
// 无需API密钥，直接调用
// ============================================================

const HF_API_URL = 'https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-xl-base-1.0';

console.log('='.repeat(60));
console.log('🎨 造像馆 API 服务');
console.log('🆕 使用 Hugging Face 免费API');
console.log('💰 成本: 完全免费');
console.log('='.repeat(60));

// 健康检查
app.get('/api/health', (req, res) => {
  res.json({
    success: true,
    message: 'Server is running',
    api: 'Hugging Face Inference API (Free)',
    model: 'Stable Diffusion XL',
    timestamp: new Date().toISOString()
  });
});

// 用户注册（简化版，返回无限积分）
app.post('/api/register', (req, res) => {
  const { phone, password } = req.body;
  const userId = `user_${Date.now()}`;

  console.log(`✅ 用户注册: ${phone} -> ${userId}`);

  res.json({
    success: true,
    message: '注册成功',
    data: {
      userId: userId,
      phone: phone,
      points: 999999 // 免费版给无限积分
    }
  });
});

// 用户登录（简化版）
app.post('/api/login', (req, res) => {
  const { phone, password } = req.body;
  const userId = `user_${phone}`;

  console.log(`✅ 用户登录: ${phone} -> ${userId}`);

  res.json({
    success: true,
    message: '登录成功',
    data: {
      userId: userId,
      phone: phone,
      points: 999999 // 免费版
    }
  });
});

// ============================================================
// 🎨 图片生成接口（完全免费）
// ============================================================

app.post('/api/generate', async (req, res) => {
  try {
    const { style, substyle, userId, image } = req.body;

    console.log(`📸 收到生成请求: ${style} - ${substyle}`);
    console.log(`👤 用户ID: ${userId || 'guest'}`);
    console.log(`📷 图片上传: ${image ? '是' : '否'}`);

    if (!style) {
      return res.status(400).json({
        success: false,
        message: '请选择风格'
      });
    }

    // 生成prompt
    const prompt = generatePrompt(style, substyle);
    const negativePrompt = 'low quality, blurry, distorted, ugly, bad anatomy, deformed, cross-eyed, double face';

    console.log(`🎨 生成prompt: ${prompt.substring(0, 50)}...`);

    // 调用Hugging Face免费API
    console.log('⏳ 正在调用Hugging Face API...');

    const hfResponse = await fetch(HF_API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        inputs: prompt,
        parameters: {
          negative_prompt: negativePrompt,
          num_inference_steps: 25,  // 平衡质量和速度
          guidance_scale: 7.5,
          width: 512,
          height: 768,
          max_new_tokens: 500
        }
      })
    });

    if (!hfResponse.ok) {
      const errorText = await hfResponse.text();
      console.error(`❌ Hugging Face API错误: ${hfResponse.status} ${errorText}`);
      throw new Error(`API错误: ${hfResponse.status}`);
    }

    // 获取图片（二进制格式）
    const buffer = await hfResponse.buffer();
    console.log(`✅ 图片生成成功! 大小: ${(buffer.length / 1024).toFixed(2)} KB`);

    // 保存图片
    const filename = `${userId || 'guest'}_${Date.now()}.png`;
    const imagePath = path.join(uploadsDir, filename);

    fs.writeFileSync(imagePath, buffer);
    console.log(`💾 图片已保存: ${filename}`);

    // 构建返回的URL
    const serverIp = req.headers.host ? req.headers.host.split(':')[0] : '121.5.33.130';
    const imageUrl = `http://${serverIp}:${PORT}/uploads/${filename}`;

    console.log(`✅ 生成完成! URL: ${imageUrl}`);
    console.log('='.repeat(60));

    res.json({
      success: true,
      imageUrl: imageUrl,
      filename: filename,
      message: '生成成功'
    });

  } catch (error) {
    console.error('❌ 生成失败:', error.message);
    console.error(error.stack);

    res.status(500).json({
      success: false,
      message: error.message || '生成失败，请稍后重试'
    });
  }
});

// ============================================================
// 🎨 Prompt生成函数
// ============================================================

function generatePrompt(style, substyle) {
  const prompts = {
    '写真': {
      '日系清新': 'portrait, soft natural lighting, japanese photography style, gentle, fresh, delicate features, beautiful, high quality, detailed',
      '欧美时尚': 'portrait, fashion photography, western style, professional lighting, high fashion, sharp, stylish, beautiful, detailed',
      '性感风': 'portrait, attractive, confident, stylish, dramatic lighting, alluring, glamorous, high quality',
      '学院风': 'portrait, youthful, school style, cute, fresh, young, innocent, beautiful',
      '甜美风': 'portrait, sweet, lovely, soft colors, innocent, adorable, charming, beautiful',
    },
    '艺术': {
      '时尚杂志': 'portrait, magazine cover style, professional photography, editorial, high fashion, polished, beautiful',
      '情节艺术': 'portrait, cinematic, storytelling, dramatic scene, artistic, emotional, high quality',
      '抽象艺术': 'portrait, artistic interpretation, abstract elements, creative, unique, artistic, detailed',
      '油画风': 'portrait, oil painting style, classical art, masterpiece, detailed, brush strokes, beautiful',
    },
    '古风': {
      '唐朝': 'portrait, tang dynasty style, ancient chinese costume, palace, elegant, royal, ornate, beautiful',
      '宋朝': 'portrait, song dynasty style, ancient chinese, scholarly, refined, graceful, elegant',
      '明朝': 'portrait, ming dynasty style, ancient chinese, royal, ornate, majestic, beautiful',
      '魏晋': 'portrait, wei jin dynasty style, ancient chinese scholar, elegant, free-spirited, graceful',
      '汉服': 'portrait, traditional chinese hanfu, elegant, classical, beautiful, graceful',
    },
    '复古': {
      '港风': 'portrait, 1980s hong kong style, vintage photography, retro, nostalgic, classic, beautiful',
      '民国': 'portrait, 1920s shanghai style, vintage chinese, nostalgic, elegant, classic',
      '胶片': 'portrait, film photography style, grainy, vintage colors, retro, classic, beautiful',
      '黑白复古': 'portrait, black and white photography, classic, timeless, monochrome, beautiful',
    },
    '婚纱': {
      '室内主纱': 'portrait, wedding photography, white wedding dress, elegant, romantic, bridal, beautiful',
      '清新森系': 'portrait, wedding photography, outdoor, forest, natural, fresh, ethereal, beautiful',
      '中式': 'portrait, traditional chinese wedding, red dress, ceremonial, cultural, beautiful',
      '浪漫夜景': 'portrait, wedding photography, night scene, romantic lighting, dreamy, beautiful',
      '海边漫步': 'portrait, beach wedding, ocean, natural light, romantic, seaside, beautiful',
    },
    '证件': {
      '一寸': 'portrait, id photo, plain background, professional lighting, front view, clear, formal, high quality',
      '二寸': 'portrait, id photo, plain background, professional lighting, front view, formal, clear',
      '小二寸': 'portrait, passport photo, plain background, professional, clear, formal, high quality',
      '五寸': 'portrait, large photo, professional quality, detailed, sharp, beautiful',
    },
  };

  const stylePrompts = prompts[style] || prompts['写真'];
  return stylePrompts[substyle] || stylePrompts['日系清新'];
}

// 根路径
app.get('/', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <title>造像馆 API</title>
      <style>
        body {
          font-family: Arial, sans-serif;
          max-width: 800px;
          margin: 50px auto;
          padding: 20px;
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          color: white;
        }
        h1 { text-shadow: 2px 2px 4px rgba(0,0,0,0.2); }
        .status {
          background: rgba(255,255,255,0.1);
          backdrop-filter: blur(10px);
          padding: 20px;
          border-radius: 10px;
          margin: 20px 0;
        }
        .endpoint {
          background: rgba(255,255,255,0.1);
          padding: 15px;
          margin: 10px 0;
          border-radius: 5px;
        }
        code {
          background: rgba(0,0,0,0.3);
          padding: 2px 6px;
          border-radius: 3px;
        }
      </style>
    </head>
    <body>
      <h1>🎨 造像馆 API 服务</h1>
      <div class="status">
        <p><strong>✅ 状态:</strong> 运行中</p>
        <p><strong>🤖 模型:</strong> Stable Diffusion XL</p>
        <p><strong>💰 费用:</strong> 完全免费 (Hugging Face API)</p>
        <p><strong>📱 额度:</strong> 每月数千次免费生成</p>
      </div>
      <h2>API 端点:</h2>
      <div class="endpoint">
        <code>GET /api/health</code> - 健康检查<br>
        <code>POST /api/register</code> - 用户注册<br>
        <code>POST /api/login</code> - 用户登录<br>
        <code>POST /api/generate</code> - 生成图片
      </div>
      <p style="margin-top: 30px;">🚀 服务已就绪，可以接收请求！</p>
    </body>
    </html>
  `);
});

// 启动服务器
app.listen(PORT, () => {
  console.log('='.repeat(60));
  console.log(`🚀 服务器已启动!`);
  console.log(`🌐 本地: http://localhost:${PORT}`);
  console.log(`🌐 外网: http://121.5.33.130:${PORT}`);
  console.log(`🤖 模型: Stable Diffusion XL (免费)`);
  console.log(`💰 费用: 完全免费`);
  console.log(`⏰ 启动时间: ${new Date().toLocaleString('zh-CN')}`);
  console.log('='.repeat(60));
  console.log('');
  console.log('📝 API文档:');
  console.log(`   GET  http://121.5.33.130:${PORT}/api/health`);
  console.log(`   POST http://121.5.33.130:${PORT}/api/generate`);
  console.log('');
  console.log('⏳ 等待请求...');
  console.log('');
});

// 优雅退出
process.on('SIGINT', () => {
  console.log('\n👋 服务器已关闭');
  process.exit(0);
});
