//
//  ImageProcessor.swift
//  ZhaoXiangGuan
//
//  图片处理工具 - 水印、压缩、Base64编码等
//

import Foundation
import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

class ImageProcessor {

    static let shared = ImageProcessor()

    private init() {}

    // MARK: - 水印相关

    /// 添加水印到图片
    func addWatermark(to image: UIImage, text: String = "造像馆 免费预览") -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)

        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }

        // 绘制原图
        image.draw(in: CGRect(origin: .zero, size: image.size))

        // 水印配置
        let fontSize = max(20, image.size.width / 25)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fontSize, weight: .medium),
            .foregroundColor: UIColor.white.withAlphaComponent(0.9),
            .strokeColor: UIColor.black.withAlphaComponent(0.5),
            .strokeWidth: -2
        ]

        let textSize = text.size(withAttributes: attributes)
        let padding: CGFloat = 20
        let watermarkRect = CGRect(
            x: image.size.width - textSize.width - padding * 2,
            y: image.size.height - textSize.height - padding * 2,
            width: textSize.width + padding * 2,
            height: textSize.height + padding
        )

        // 绘制半透明背景
        context.setFillColor(UIColor.black.withAlphaComponent(0.3).cgColor)
        context.fill(watermarkRect)

        // 绘制文字
        let textRect = CGRect(
            x: image.size.width - textSize.width - padding,
            y: image.size.height - textSize.height - padding,
            width: textSize.width,
            height: textSize.height
        )
        text.draw(in: textRect, withAttributes: attributes)

        let watermarkedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return watermarkedImage
    }

    /// 添加右下角角标水印
    func addCornerWatermark(to image: UIImage, text: String = "造像馆") -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)

        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }

        image.draw(in: CGRect(origin: .zero, size: image.size))

        // 圆形角标配置
        let cornerSize: CGFloat = min(image.size.width, image.size.height) * 0.15
        let cornerRect = CGRect(
            x: image.size.width - cornerSize - 15,
            y: image.size.height - cornerSize - 15,
            width: cornerSize,
            height: cornerSize
        )

        // 绘制圆形背景
        context.setFillColor(UIColor.black.withAlphaComponent(0.6).cgColor)
        context.fillEllipse(in: cornerRect)

        // 绘制图标或文字
        let fontSize = cornerSize * 0.3
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fontSize, weight: .bold),
            .foregroundColor: UIColor.white
        ]

        let textSize = text.size(withAttributes: attributes)
        let textRect = CGRect(
            x: cornerRect.midX - textSize.width / 2,
            y: cornerRect.midY - textSize.height / 2,
            width: textSize.width,
            height: textSize.height
        )

        text.draw(in: textRect, withAttributes: attributes)

        let watermarkedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return watermarkedImage
    }

    // MARK: - 图片压缩相关

    /// 压缩图片到指定大小（KB）
    func compressImage(_ image: UIImage, toMaxSizeKB maxSizeKB: Int) -> Data? {
        var compression: CGFloat = 1.0
        let maxBytes = maxSizeKB * 1024

        guard var imageData = image.jpegData(compressionQuality: compression) else {
            return nil
        }

        while imageData.count > maxBytes && compression > 0.1 {
            compression -= 0.1
            if let data = image.jpegData(compressionQuality: compression) {
                imageData = data
            } else {
                break
            }
        }

        return imageData
    }

    /// 压缩图片到指定尺寸
    func resizeImage(_ image: UIImage, toMaxSize maxSize: CGSize) -> UIImage? {
        let aspectRatio = image.size.width / image.size.height
        var newSize = maxSize

        if image.size.width > image.size.height {
            newSize = CGSize(
                width: maxSize.width,
                height: maxSize.width / aspectRatio
            )
        } else {
            newSize = CGSize(
                width: maxSize.height * aspectRatio,
                height: maxSize.height
            )
        }

        UIGraphicsBeginImageContextWithOptions(newSize, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage
    }

    /// 压缩图片用于上传（限制尺寸和文件大小）
    func prepareImageForUpload(_ image: UIImage) -> Data? {
        // 首先调整尺寸（最大边长1080）
        let maxDimension: CGFloat = 1080
        let resizedImage = resizeImage(image, toMaxSize: CGSize(width: maxDimension, height: maxDimension))

        // 然后压缩到2MB以内
        let targetSizeKB = 2048
        return compressImage(resizedImage ?? image, toMaxSizeKB: targetSizeKB)
    }

    // MARK: - Base64 编码

    /// 将图片转换为 Base64 字符串
    func imageToBase64(_ image: UIImage) -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            return nil
        }
        return imageData.base64EncodedString()
    }

    /// 将 Base64 字符串转换为图片
    func base64ToImage(_ base64String: String) -> UIImage? {
        guard let imageData = Data(base64Encoded: base64String) else {
            return nil
        }
        return UIImage(data: imageData)
    }

    // MARK: - 滤镜效果

    /// 应用简单的滤镜效果（模拟不同风格）
    func applyFilter(to image: UIImage, style: ArtStyle) -> UIImage? {
        guard let ciImage = CIImage(image: image) else {
            return nil
        }

        let filter: CIFilter & CIFilterConstructor

        switch style {
        case .oilPainting:
            return applyOilPaintingEffect(to: ciImage)
        case .watercolor:
            return applyWatercolorEffect(to: ciImage)
        case .ink:
            return applyInkEffect(to: ciImage)
        case .anime:
            return applyAnimeEffect(to: ciImage)
        case .vintage:
            return applyVintageEffect(to: ciImage)
        default:
            return applyColorTone(to: ciImage, color: style.accentColor)
        }
    }

    // 油画效果
    private func applyOilPaintingEffect(to image: CIImage) -> UIImage? {
        let filter = CIFilter.photoEffectTransfer()
        filter.inputImage = image
        filter.outputImage.flatMap { outputImage in
            let context = CIContext()
            guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
                return nil
            }
            return UIImage(cgImage: cgImage)
        }
    }

    // 水彩效果
    private func applyWatercolorEffect(to image: CIImage) -> UIImage? {
        let filter = CIFilter.photoEffectFade()
        filter.inputImage = image
        filter.outputImage.flatMap { outputImage in
            let context = CIContext()
            guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
                return nil
            }
            return UIImage(cgImage: cgImage)
        }
    }

    // 水墨效果
    private func applyInkEffect(to image: CIImage) -> UIImage? {
        let filter = CIFilter.photoEffectNoir()
        filter.inputImage = image
        filter.outputImage.flatMap { outputImage in
            let context = CIContext()
            guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
                return nil
            }
            return UIImage(cgImage: cgImage)
        }
    }

    // 动漫效果
    private func applyAnimeEffect(to image: CIImage) -> UIImage? {
        let filter = CIFilter.photoEffectProcess()
        filter.inputImage = image
        filter.outputImage.flatMap { outputImage in
            let context = CIContext()
            guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
                return nil
            }
            return UIImage(cgImage: cgImage)
        }
    }

    // 复古效果
    private func applyVintageEffect(to image: CIImage) -> UIImage? {
        let filter = CIFilter.photoEffectInstant()
        filter.inputImage = image
        filter.outputImage.flatMap { outputImage in
            let context = CIContext()
            guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
                return nil
            }
            return UIImage(cgImage: cgImage)
        }
    }

    // 色调效果
    private func applyColorTone(to image: CIImage, color: Color) -> UIImage? {
        guard let ciColor = CIColor(color: UIColor(.init(color))) else {
            return nil
        }

        let filter = CIFilter.colorMonochrome()
        filter.inputImage = image
        filter.color = ciColor
        filter.intensity = 0.3

        return filter.outputImage.flatMap { outputImage in
            let context = CIContext()
            guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
                return nil
            }
            return UIImage(cgImage: cgImage)
        }
    }

    // MARK: - 图片裁剪

    /// 裁剪图片到圆形
    func cropToCircle(_ image: UIImage) -> UIImage? {
        let minDimension = min(image.size.width, image.size.height)
        let cropRect = CGRect(
            x: (image.size.width - minDimension) / 2,
            y: (image.size.height - minDimension) / 2,
            width: minDimension,
            height: minDimension
        )

        guard let cgImage = image.cgImage?.cropping(to: cropRect) else {
            return nil
        }

        UIGraphicsBeginImageContextWithOptions(CGSize(width: minDimension, height: minDimension), false, image.scale)
        let context = UIGraphicsGetCurrentContext()

        context?.addEllipse(in: CGRect(origin: .zero, size: CGSize(width: minDimension, height: minDimension)))
        context?.clip()

        UIImage(cgImage: cgImage).draw(in: CGRect(origin: .zero, size: CGSize(width: minDimension, height: minDimension)))

        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return croppedImage
    }
}

// MARK: - Color Extension

extension Color {
    init(uiColor: UIColor) {
        self.init(red: Double(uiColor.cgColor.components?[0] ?? 0),
                  green: Double(uiColor.cgColor.components?[1] ?? 0),
                  blue: Double(uiColor.cgColor.components?[2] ?? 0))
    }
}
