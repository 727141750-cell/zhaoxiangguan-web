//
//  HomeView.swift
//  ZhaoXiangGuan
//
//  首页 - 拍摄自拍/相册上传
//

import SwiftUI
import PhotosUI

struct HomeView: View {
    @State private var showingCamera = false
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var navigateToStyleSelection = false
    @State private var showPermissionAlert = false
    @State private var permissionType: PermissionType = .camera

    enum PermissionType {
        case camera
        case photoLibrary
    }

    var body: some View {
        NavigationView {
            ZStack {
                // 背景渐变
                LinearGradient(
                    colors: [Color(red: 0.95, green: 0.95, blue: 0.97), Color(red: 0.98, green: 0.96, blue: 0.98)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // 顶部标题区域
                    VStack(spacing: 8) {
                        Text("造像馆")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.primary)

                        Text("自拍秒变艺术大片")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)

                    Spacer()

                    // 风格示例轮播（简化版，用静态卡片展示）
                    StylePreviewCarousel()
                        .padding(.horizontal, 20)

                    Spacer()

                    // 主要操作按钮区域
                    VStack(spacing: 20) {
                        // 拍摄自拍按钮
                        Button(action: {
                            checkCameraPermission()
                        }) {
                            HStack {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 24))
                                Text("拍摄自拍")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(
                                LinearGradient(
                                    colors: [Color.blue, Color.blue.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(30)
                            .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                        }

                        // 相册上传按钮
                        Button(action: {
                            checkPhotoLibraryPermission()
                        }) {
                            HStack {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.system(size: 24))
                                Text("相册上传")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color.white)
                            .cornerRadius(30)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal, 30)

                    // 底部说明文字
                    VStack(spacing: 8) {
                        Text("仅需一张自拍，AI自动生成10种风格")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)

                        HStack(spacing: 20) {
                            FeatureLabel(icon: "bolt.fill", text: "秒级生成")
                            FeatureLabel(icon: "paintbrush.fill", text: "10种风格")
                            FeatureLabel(icon: "sparkles", text: "高清无水印")
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $showingCamera) {
            ImagePicker(sourceType: .camera, selectedImage: $selectedImage, navigateToStyle: $navigateToStyleSelection)
        }
        .fullScreenCover(isPresented: $showingImagePicker) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage, navigateToStyle: $navigateToStyleSelection)
        }
        .background(
            NavigationLink(destination: StyleSelectionView(selectedImage: selectedImage), isActive: $navigateToStyleSelection) {
                EmptyView()
            }
        )
        .alert("需要权限", isPresented: $showPermissionAlert) {
            Button("取消", role: .cancel) { }
            Button("去设置") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text(permissionType == .camera ? "请在设置中开启相机权限" : "请在设置中开启相册权限")
        }
    }

    // 检查相机权限
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showingCamera = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        showingCamera = true
                    } else {
                        permissionType = .camera
                        showPermissionAlert = true
                    }
                }
            }
        default:
            permissionType = .camera
            showPermissionAlert = true
        }
    }

    // 检查相册权限
    private func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized, .limited:
            showingImagePicker = true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        showingImagePicker = true
                    } else {
                        permissionType = .photoLibrary
                        showPermissionAlert = true
                    }
                }
            }
        default:
            permissionType = .photoLibrary
            showPermissionAlert = true
        }
    }
}

// 风格预览轮播（简化版）
struct StylePreviewCarousel: View {
    let styles: [ArtStyle] = [.oilPainting, .watercolor, .anime, .beachSunset, .cherryBlossom]

    var body: some View {
        VStack(spacing: 12) {
            ForEach(styles.prefix(3)) { style in
                StylePreviewCard(style: style)
            }
        }
    }
}

// 风格预览卡片
struct StylePreviewCard: View {
    let style: ArtStyle

    var body: some View {
        HStack(spacing: 12) {
            // 模拟预览图
            RoundedRectangle(cornerRadius: 12)
                .fill(style.accentColor.opacity(0.3))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "photo")
                        .foregroundColor(style.accentColor)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(style.rawValue)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)

                Text(style.description)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// 特性标签
struct FeatureLabel: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(text)
                .font(.system(size: 12))
        }
        .foregroundColor(.secondary)
    }
}

#Preview {
    HomeView()
}
