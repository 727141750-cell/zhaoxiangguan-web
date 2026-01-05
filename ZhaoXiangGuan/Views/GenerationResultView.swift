//
//  GenerationResultView.swift
//  ZhaoXiangGuan
//
//  生成结果页面 - 预览/重新生成/下载
//

import SwiftUI
import Photos

struct GenerationResultView: View {
    @ObservedObject var result: GenerationResult
    @EnvironmentObject var userSession: UserSession
    @EnvironmentObject var pointsManager: PointsManager
    @State private var isRegenerating = false
    @State private var showLoginAlert = false
    @State private var showRechargeAlert = false
    @State private var showDownloadSuccess = false
    @State private var downloadedImage: UIImage?
    @Environment(\.dismiss) var dismiss

    private let downloadCost = 100

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 顶部导航栏
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }

                    Spacer()

                    Text(result.style.rawValue)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()

                    Button(action: {
                        // 分享功能
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)

                Spacer()

                // 图片预览区域
                ZStack {
                    if let uiImage = downloadedImage {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else if isRegenerating {
                        // 生成中动画
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.white)

                            Text("AI 正在为你打造专属艺术照")
                                .font(.system(size: 16))
                                .foregroundColor(.white)

                            Text("请稍候...")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    } else {
                        // 显示原图占位（实际应该显示生成后的图片）
                        if let originalImage = UIImage(data: result.originalImage) {
                            Image(uiImage: originalImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .overlay(
                                    // 水印
                                    VStack {
                                        Spacer()
                                        HStack {
                                            Spacer()
                                            Text("造像馆 免费预览")
                                                .font(.system(size: 12))
                                                .foregroundColor(.white.opacity(0.8))
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .background(Color.black.opacity(0.5))
                                                .cornerRadius(8)
                                        }
                                        .padding()
                                    }
                                )
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()

                Spacer()

                // 底部操作区域
                VStack(spacing: 16) {
                    // 当前积分显示（登录后）
                    if userSession.isLoggedIn {
                        HStack {
                            Spacer()
                            HStack(spacing: 4) {
                                Image(systemName: "sparkles")
                                    .foregroundColor(.yellow)
                                Text("\(pointsManager.currentPoints)")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("积分")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                            .foregroundColor(.primary)
                            Spacer()
                        }
                    }

                    // 重新生成按钮
                    Button(action: {
                        regenerateImage()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 18))
                            Text("重新生成")
                                .font(.system(size: 17, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(26)
                    }
                    .disabled(isRegenerating)

                    // 无水印下载按钮
                    Button(action: {
                        downloadImage()
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 18))
                            Text("无水印下载")
                                .font(.system(size: 17, weight: .semibold))
                            if userSession.isLoggedIn {
                                Text("\(downloadCost) 积分")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        .foregroundColor(userSession.isLoggedIn ? .white : .gray)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            userSession.isLoggedIn
                            ? (pointsManager.hasEnoughPoints(downloadCost) ? Color.blue : Color.orange)
                            : Color.gray.opacity(0.5)
                        )
                        .cornerRadius(26)
                    }
                    .disabled(isRegenerating || (!userSession.isLoggedIn))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
                .background(
                    LinearGradient(
                        colors: [Color.black.opacity(0.8), Color.clear],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
            }
        }
        .navigationBarHidden(true)
        .alert("提示", isPresented: $showLoginAlert) {
            Button("取消", role: .cancel) { }
            Button("去登录") {
                // 跳转到登录页
            }
        } message: {
            Text("请先登录后下载无水印图片")
        }
        .alert("积分不足", isPresented: $showRechargeAlert) {
            Button("取消", role: .cancel) { }
            Button("去充值") {
                // 跳转到充值页
            }
        } message: {
            Text("积分余额不足，请前往充值")
        }
        .alert("下载成功", isPresented: $showDownloadSuccess) {
            Button("确定") { }
        } message: {
            Text("已保存到相册，快去查看吧")
        }
        .onAppear {
            // 模拟生成过程
            simulateGeneration()
        }
    }

    // 模拟图片生成
    private func simulateGeneration() {
        isRegenerating = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isRegenerating = false
            // 实际项目中这里会调用API生成图片
            // 目前用原图作为示例
            if let originalImage = UIImage(data: result.originalImage) {
                // 应用简单的滤镜效果模拟
                downloadedImage = applyStyleEffect(to: originalImage, style: result.style)
            }
        }
    }

    // 重新生成
    private func regenerateImage() {
        simulateGeneration()
    }

    // 下载图片
    private func downloadImage() {
        guard let image = downloadedImage else { return }

        // 检查登录状态
        if !userSession.isLoggedIn {
            showLoginAlert = true
            return
        }

        // 检查积分
        if !pointsManager.hasEnoughPoints(downloadCost) {
            showRechargeAlert = true
            return
        }

        // 保存到相册
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized || status == .limited {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)

                DispatchQueue.main.async {
                    // 扣除积分
                    pointsManager.deductPoints(downloadCost)
                    showDownloadSuccess = true
                }
            }
        }
    }

    // 应用风格效果（简化版，实际应该调用AI API）
    private func applyStyleEffect(to image: UIImage, style: ArtStyle) -> UIImage {
        // 这里只是示例，实际应该调用后端AI API
        // 简单调整一些参数来模拟不同风格

        guard let ciImage = CIImage(image: image) else { return image }

        let filter = CIFilter(name: "CIPhotoEffectFade")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)

        if let outputImage = filter?.outputImage,
           let cgImage = CIContext(options: nil).createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgImage)
        }

        return image
    }
}

#Preview {
    GenerationResultView(
        result: GenerationResult(style: .oilPainting, originalImage: Data())
    )
    .environmentObject(UserSession())
    .environmentObject(PointsManager())
}
