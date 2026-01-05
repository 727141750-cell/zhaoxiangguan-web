//
//  DownloadsView.swift
//  ZhaoXiangGuan
//
//  我的下载页面
//

import SwiftUI

struct DownloadsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var downloadedImages: [DownloadedItem] = []

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.95, green: 0.95, blue: 0.97)
                    .ignoresSafeArea()

                if downloadedImages.isEmpty {
                    // 空状态
                    VStack(spacing: 16) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)

                        Text("还没有下载记录")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)

                        Text("下载的无水印图片会显示在这里")
                            .font(.system(size: 14))
                            .foregroundColor(.tertiary)
                    }
                } else {
                    // 下载列表
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ], spacing: 16) {
                            ForEach(downloadedImages) { item in
                                DownloadItemCard(item: item)
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("我的下载")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// 下载项数据模型
struct DownloadedItem: Identifiable {
    let id = UUID()
    let style: ArtStyle
    let imageData: Data
    let downloadDate: Date
}

// 下载项卡片
struct DownloadItemCard: View {
    let item: DownloadedItem

    var body: some View {
        VStack(spacing: 8) {
            // 图片预览
            if let image = UIImage(data: item.imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            // 风格名称
            Text(item.style.rawValue)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(1)

            // 下载时间
            Text(formatDate(item.downloadDate))
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    DownloadsView()
}
