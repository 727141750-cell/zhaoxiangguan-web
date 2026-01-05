//
//  RechargeHistoryView.swift
//  ZhaoXiangGuan
//
//  充值记录页面
//

import SwiftUI

struct RechargeHistoryView: View {
    @EnvironmentObject var pointsManager: PointsManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.95, green: 0.95, blue: 0.97)
                    .ignoresSafeArea()

                let history = pointsManager.getRechargeHistory()

                if history.isEmpty {
                    // 空状态
                    VStack(spacing: 16) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)

                        Text("还没有充值记录")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)

                        Text("充值记录会显示在这里")
                            .font(.system(size: 14))
                            .foregroundColor(.tertiary)
                    }
                } else {
                    // 充值记录列表
                    ScrollView {
                        VStack(spacing: 1) {
                            ForEach(
                                history.reversed().enumerated().map { ($0.offset, $0.element) },
                                id: \.offset
                            ) { _, record in
                                RechargeRecordRow(record: record)
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .padding()
                    }
                }
            }
            .navigationTitle("充值记录")
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

// 充值记录行
struct RechargeRecordRow: View {
    let record: [String: Any]

    var body: some View {
        HStack(spacing: 16) {
            // 图标
            Circle()
                .fill(Color.green.opacity(0.1))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "plus")
                        .foregroundColor(.green)
                )

            // 充值信息
            VStack(alignment: .leading, spacing: 4) {
                if let tier = record["tier"] as? String {
                    Text(tier)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                }

                if let date = record["date"] as? TimeInterval {
                    Text(formatDate(date))
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // 充值金额和积分
            VStack(alignment: .trailing, spacing: 4) {
                if let price = record["price"] as? Int {
                    Text("¥\(price)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                }

                if let points = record["points"] as? Int {
                    Text("+\(points) 积分")
                        .font(.system(size: 13))
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
    }

    private func formatDate(_ timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    RechargeHistoryView()
        .environmentObject(PointsManager())
}
