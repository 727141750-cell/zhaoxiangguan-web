//
//  ArtStyle.swift
//  ZhaoXiangGuan
//
//  艺术风格数据模型
//

import Foundation
import SwiftUI

// 艺术风格枚举
enum ArtStyle: String, CaseIterable, Identifiable {
    case oilPainting = "欧式油画风"
    case watercolor = "清新水彩风"
    case ink = "国潮水墨风"
    case anime = "动漫二次元风"
    case vintage = "复古胶片风"
    case beachSunset = "海边落日风"
    case snowyMountain = "雪山之巅风"
    case cherryBlossom = "樱花秘境风"
    case ancientTown = "古城巷陌风"
    case forest = "森系治愈风"

    var id: String { rawValue }

    // 风格描述
    var description: String {
        switch self {
        case .oilPainting:
            return "复古质感拉满，秒变名画主角"
        case .watercolor:
            return "温柔通透，自带滤镜感"
        case .ink:
            return "东方意境，尽显古韵之美"
        case .anime:
            return "打破次元壁，变身漫画主角"
        case .vintage:
            return "港风怀旧，复刻时光记忆"
        case .beachSunset:
            return "椰林沙滩，邂逅浪漫余晖"
        case .snowyMountain:
            return "云海翻涌，解锁清冷高级感"
        case .cherryBlossom:
            return "落樱缤纷，定格春日浪漫"
        case .ancientTown:
            return "青砖黛瓦，邂逅人间烟火"
        case .forest:
            return "绿野仙踪，拥抱自然静谧"
        }
    }

    // 风格分类
    var category: StyleCategory {
        switch self {
        case .oilPainting, .watercolor, .ink, .anime, .vintage:
            return .artistic
        case .beachSunset, .snowyMountain, .cherryBlossom, .ancientTown, .forest:
            return .scenery
        }
    }

    // 预览图片名称（实际项目中需要替换为真实图片）
    var previewImageName: String {
        return "style_\(rawValue)"
    }

    // 风格颜色
    var accentColor: Color {
        switch self {
        case .oilPainting: return Color(red: 0.6, green: 0.4, blue: 0.2)
        case .watercolor: return Color(red: 0.7, green: 0.85, blue: 0.9)
        case .ink: return Color(red: 0.3, green: 0.3, blue: 0.35)
        case .anime: return Color(red: 1.0, green: 0.4, blue: 0.6)
        case .vintage: return Color(red: 0.8, green: 0.6, blue: 0.4)
        case .beachSunset: return Color(red: 1.0, green: 0.7, blue: 0.3)
        case .snowyMountain: return Color(red: 0.7, green: 0.8, blue: 0.95)
        case .cherryBlossom: return Color(red: 1.0, green: 0.75, blue: 0.8)
        case .ancientTown: return Color(red: 0.5, green: 0.45, blue: 0.4)
        case .forest: return Color(red: 0.3, green: 0.6, blue: 0.35)
        }
    }
}

// 风格分类
enum StyleCategory: String, CaseIterable {
    case artistic = "艺术写真"
    case scenery = "风景人像"
}

// 生成结果
struct GenerationResult: Identifiable {
    let id = UUID()
    let style: ArtStyle
    let originalImage: Data
    var generatedImage: Data?
    var isGenerating: Bool = false
    let createdAt: Date

    init(style: ArtStyle, originalImage: Data) {
        self.style = style
        self.originalImage = originalImage
        self.createdAt = Date()
    }
}
