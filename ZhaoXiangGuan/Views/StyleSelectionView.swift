//
//  StyleSelectionView.swift
//  ZhaoXiangGuan
//
//  风格选择页面 - 10种风格展示
//

import SwiftUI

struct StyleSelectionView: View {
    let selectedImage: UIImage?
    @State private var selectedStyle: ArtStyle?
    @State private var navigateToResult = false
    @State private var generatedResult: GenerationResult?
    @EnvironmentObject var pointsManager: PointsManager

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.95, green: 0.95, blue: 0.97)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // 原图预览区域
                        VStack(spacing: 12) {
                            Text("选择你喜欢的风格")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)

                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                            }
                        }
                        .padding(.top, 20)

                        // 艺术写真风格
                        StyleCategorySection(
                            title: "艺术写真风格",
                            styles: [.oilPainting, .watercolor, .ink, .anime, .vintage],
                            selectedStyle: $selectedStyle
                        )

                        // 风景人像风格
                        StyleCategorySection(
                            title: "风景人像风格",
                            styles: [.beachSunset, .snowyMountain, .cherryBlossom, .ancientTown, .forest],
                            selectedStyle: $selectedStyle
                        )

                        // 底部按钮
                        VStack(spacing: 12) {
                            Button(action: {
                                if let style = selectedStyle, let imageData = selectedImage?.jpegData(compressionQuality: 0.8) {
                                    let result = GenerationResult(style: style, originalImage: imageData)
                                    generatedResult = result
                                    navigateToResult = true
                                }
                            }) {
                                Text("确认生成")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(
                                        selectedStyle != nil
                                        ? LinearGradient(colors: [Color.blue, Color.blue.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
                                        : LinearGradient(colors: [Color.gray], startPoint: .leading, endPoint: .trailing)
                                    )
                                    .cornerRadius(28)
                            }
                            .disabled(selectedStyle == nil)
                            .padding(.horizontal, 30)

                            Text("AI自动处理，几秒即可完成")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("返回") {
                        // 返回上一页
                    }
                }
            }
        }
        .background(
            NavigationLink(destination: {
                if let result = generatedResult {
                    GenerationResultView(result: result)
                }
            }, isActive: $navigateToResult) {
                EmptyView()
            }
        )
    }
}

// 风格分类区块
struct StyleCategorySection: View {
    let title: String
    let styles: [ArtStyle]
    @Binding var selectedStyle: ArtStyle?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
                .padding(.horizontal, 20)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 16) {
                ForEach(styles) { style in
                    StyleCard(
                        style: style,
                        isSelected: selectedStyle == style
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3)) {
                            selectedStyle = style
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// 风格卡片
struct StyleCard: View {
    let style: ArtStyle
    let isSelected: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 12) {
                // 预览图占位
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [style.accentColor.opacity(0.6), style.accentColor.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 120)
                    .overlay(
                        Image(systemName: "photo.artframe")
                            .font(.system(size: 36))
                            .foregroundColor(.white.opacity(0.8))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? style.accentColor : Color.clear, lineWidth: 3)
                    )

                // 风格名称和描述
                VStack(alignment: .leading, spacing: 4) {
                    Text(style.rawValue)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)

                    Text(style.description)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: isSelected ? style.accentColor.opacity(0.3) : Color.black.opacity(0.08), radius: isSelected ? 12 : 5, x: 0, y: 2)

            // 选中标记
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(style.accentColor)
                    .font(.system(size: 24))
                    .padding(.top, 8)
                    .padding(.trailing, 8)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
            }
        }
    }
}

#Preview {
    StyleSelectionView(selectedImage: UIImage(systemName: "person.fill"))
}
