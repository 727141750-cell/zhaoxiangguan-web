//
//  StyleGalleryView.swift
//  ZhaoXiangGuan
//
//  风格画廊页面 - 展示所有风格
//

import SwiftUI

struct StyleGalleryView: View {
    @State private var selectedCategory: StyleCategory = .artistic

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.95, green: 0.95, blue: 0.97)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // 分类选择器
                    Picker("风格分类", selection: $selectedCategory) {
                        ForEach(StyleCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                    // 风格列表
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 20) {
                            ForEach(stylesForCategory(selectedCategory)) { style in
                                StyleGalleryCard(style: style)
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle("风格画廊")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func stylesForCategory(_ category: StyleCategory) -> [ArtStyle] {
        return ArtStyle.allCases.filter { $0.category == category }
    }
}

// 风格画廊卡片
struct StyleGalleryCard: View {
    let style: ArtStyle

    var body: some View {
        VStack(spacing: 12) {
            // 预览图
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [style.accentColor.opacity(0.7), style.accentColor.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 180)
                .overlay(
                    Image(systemName: "photo.artframe")
                        .font(.system(size: 48))
                        .foregroundColor(.white.opacity(0.8))
                )

            // 风格信息
            VStack(alignment: .leading, spacing: 6) {
                Text(style.rawValue)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)

                Text(style.description)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    StyleGalleryView()
}
