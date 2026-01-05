//
//  RechargeView.swift
//  ZhaoXiangGuan
//
//  充值页面
//

import SwiftUI

struct RechargeView: View {
    @EnvironmentObject var pointsManager: PointsManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedTier: PointsManager.RechargeTier?
    @State private var isProcessing = false
    @State private var showSuccess = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.95, green: 0.95, blue: 0.97)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // 当前积分展示
                        VStack(spacing: 8) {
                            Text("当前积分")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)

                            Text("\(pointsManager.currentPoints)")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.primary)
                        }
                        .padding(.top, 30)

                        // 充值档位
                        VStack(alignment: .leading, spacing: 16) {
                            Text("选择充值档位")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                                .padding(.horizontal, 20)

                            ForEach(PointsManager.RechargeTier.allCases, id: \.title) { tier in
                                RechargeTierCard(
                                    tier: tier,
                                    isSelected: selectedTier == tier
                                )
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedTier = tier
                                    }
                                }
                            }
                        }

                        // 说明文字
                        VStack(alignment: .leading, spacing: 12) {
                            Text("充值说明")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)

                            VStack(alignment: .leading, spacing: 8) {
                                HStack(alignment: .top, spacing: 8) {
                                    Text("•")
                                        .foregroundColor(.secondary)
                                    Text("充值后积分立即到账，可用于下载无水印图片")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                }
                                HStack(alignment: .top, spacing: 8) {
                                    Text("•")
                                        .foregroundColor(.secondary)
                                    Text("每下载一张无水印图片消耗100积分")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                }
                                HStack(alignment: .top, spacing: 8) {
                                    Text("•")
                                        .foregroundColor(.secondary)
                                    Text("积分不可提现、不可转赠")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .padding(.horizontal, 20)

                        // 充值按钮
                        Button(action: processRecharge) {
                            HStack {
                                if isProcessing {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    if let tier = selectedTier {
                                        Text("支付 ¥\(tier.price)")
                                            .font(.system(size: 18, weight: .semibold))
                                    } else {
                                        Text("请选择充值档位")
                                            .font(.system(size: 18, weight: .semibold))
                                    }
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                selectedTier != nil && !isProcessing
                                ? LinearGradient(colors: [Color.blue, Color.blue.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
                                : LinearGradient(colors: [Color.gray], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(27)
                        }
                        .padding(.horizontal, 20)
                        .disabled(selectedTier == nil || isProcessing)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("积分充值")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
        .alert("充值成功", isPresented: $showSuccess) {
            Button("确定") {
                dismiss()
            }
        } message: {
            if let tier = selectedTier {
                Text("成功充值 \(tier.points) 积分")
            }
        }
    }

    private func processRecharge() {
        guard let tier = selectedTier else { return }

        isProcessing = true

        // 模拟支付处理
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            pointsManager.recharge(tier: tier) { success in
                isProcessing = false
                if success {
                    showSuccess = true
                }
            }
        }
    }
}

// 充值档位卡片
struct RechargeTierCard: View {
    let tier: PointsManager.RechargeTier
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 16) {
            // 左侧价格信息
            VStack(alignment: .leading, spacing: 6) {
                Text(tier.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)

                Text("¥\(tier.price) → \(tier.points)积分")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }

            Spacer()

            // 右侧优惠信息
            VStack(alignment: .trailing, spacing: 6) {
                Text("约 ¥\(String(format: "%.1f", tier.perPhotoCost))/张")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.blue)

                Text("可下载 \(tier.points / 100) 张")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
        .background(
            isSelected
            ? Color.blue.opacity(0.05)
            : Color.white
        )
        .cornerRadius(16)
        .shadow(color: isSelected ? Color.blue.opacity(0.2) : Color.black.opacity(0.05), radius: isSelected ? 8 : 4, x: 0, y: 2)
        .overlay(
            VStack {
                HStack {
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 24))
                    }
                }
                Spacer()
            }
            .padding(12)
        )
    }
}

#Preview {
    RechargeView()
        .environmentObject(PointsManager())
}
