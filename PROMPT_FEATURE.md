# 隐藏提示词功能说明

## 功能概述

为每个子风格配置了详细的英文提示词，用户无法看到这些提示词，但它们会被发送到后端API用于AI图像生成。每次点击"重新生成"时，会在保持主题不变的情况下随机添加变化元素，产生不同的效果。

## 数据结构

```javascript
const styleConfigs = {
    '主风格': {
        '子风格': {
            prompt: '基础提示词（详细描述拍摄风格、光线、构图等）',
            variations: ['变化1', '变化2', '变化3', ...] // 5种随机变化
        }
    }
}
```

## 提示词构成

每次生成时，完整提示词 = **基础提示词** + **随机选择1-2个变化元素**

### 示例：写真 -> 日系清新

**基础提示词：**
```
Japanese portrait photography, soft natural lighting, fresh and clean aesthetic,
pastel colors, gentle smile, outdoor garden background, bokeh effect,
shot on Fujifilm, 85mm lens, f/1.8, high resolution, detailed skin texture
```

**随机变化（每次选1-2个）：**
- `with cherry blossoms` - 樱花
- `with sunlight filtering through leaves` - 阳光透过树叶
- `with blue sky background` - 蓝天背景
- `with soft wind blowing hair` - 微风吹拂头发
- `with natural candid expression` - 自然抓拍表情

**可能的组合示例：**
```
// 第一次生成
Japanese portrait photography, soft natural lighting, fresh and clean aesthetic,
pastel colors, gentle smile, outdoor garden background, bokeh effect,
shot on Fujifilm, 85mm lens, f/1.8, high resolution, detailed skin texture,
with cherry blossoms, with blue sky background

// 第二次生成（点击重新生成）
Japanese portrait photography, soft natural lighting, fresh and clean aesthetic,
pastel colors, gentle smile, outdoor garden background, bokeh effect,
shot on Fujifilm, 85mm lens, f/1.8, high resolution, detailed skin texture,
with sunlight filtering through leaves

// 第三次生成（再次点击重新生成）
Japanese portrait photography, soft natural lighting, fresh and clean aesthetic,
pastel colors, gentle smile, outdoor garden background, bokeh effect,
shot on Fujifilm, 85mm lens, f/1.8, high resolution, detailed skin texture,
with soft wind blowing hair
```

## 已配置的风格

### 写真
- **日系清新**: 日系摄影、柔和光线、清新自然
- **欧美时尚**: 高级时尚、杂志大片、戏剧光线
- **性感风**: 魅力摄影、优雅诱人、黄金时刻光线
- **学院风**: 校园青春、明亮日光、学院风格
- **甜美风**: 可爱甜美、柔和色彩、天然美

### 艺术
- **时尚杂志**: 高端时尚杂志、戏剧编辑光线
- **情节艺术**: 电影质感、故事氛围、电影影响
- **抽象艺术**: 抽象肖像、艺术扭曲、实验技术
- **油画风**: 油画风格、古典艺术技术、丰富纹理

### 古风
- **唐朝**: 唐代宫廷、华丽丝绸、牡丹花
- **宋朝**: 宋代雅致、水墨画影响、文人气息
- **明朝**: 明代华丽、刺绣龙袍、紫禁城
- **魏晋**: 魏晋风流、竹林七贤、诗意氛围
- **汉服**: 传统汉服、丝绸长袍、优雅刺绣

### 复古
- **港风**: 80年代香港、霓虹灯光、王家卫风格
- **民国**: 30年代上海、旗袍、Art Deco
- **胶片**: 复古胶片、Kodak Portra、温暖色调
- **黑白复古**: 经典黑白、高对比度、戏剧阴影

### 婚纱
- **室内主纱**: 豪华婚纱、教堂、柔和自然光
- **清新森系**: 森林婚纱、自然波西米亚、花冠
- **中式**: 传统中式婚礼、红旗袍、龙凤呈祥
- **浪漫夜景**: 浪漫夜景、城市灯光、星空
- **海边漫步**: 海滩婚纱、金色日落、海浪

### 证件
- **一寸**: 专业证件照、1寸、白色背景
- **二寸**: 专业证件照、2寸、护照风格
- **小二寸**: 护照尺寸、正式证件照
- **五寸**: 大尺寸证件照、高分辨率

## API调用

后端会收到以下参数：

```json
{
    "image": "base64编码的图片",
    "style": "写真",
    "substyle": "日系清新",
    "prompt": "Japanese portrait photography, soft natural lighting, ... with cherry blossoms, with blue sky background"
}
```

## 调试

打开浏览器开发者工具（F12）的Console标签，可以看到每次生成时使用的完整提示词：

```
生成提示词: Japanese portrait photography, soft natural lighting, fresh and clean aesthetic,
pastel colors, gentle smile, outdoor garden background, bokeh effect,
shot on Fujifilm, 85mm lens, f/1.8, high resolution, detailed skin texture,
with cherry blossoms, with blue sky background
```

## 自定义提示词

您可以在 `web-preview.html` 文件的 `styleConfigs` 对象中修改任何子风格的提示词：

```javascript
'写真': {
    '日系清新': {
        prompt: '您的基础提示词',
        variations: ['变化1', '变化2', '变化3', '变化4', '变化5']
    }
}
```

提示词建议：
- 描述拍摄风格（portrait photography, fashion photography等）
- 描述光线（soft natural lighting, dramatic lighting, golden hour等）
- 描述构图（close-up, full body, bokeh effect等）
- 描述氛围（elegant, romantic, energetic等）
- 描述技术细节（85mm lens, f/1.8, 4K resolution等）
- 描述颜色（pastel colors, warm tones, black and white等）
