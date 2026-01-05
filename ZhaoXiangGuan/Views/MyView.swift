//
//  MyView.swift
//  ZhaoXiangGuan
//
//  个人中心页面 - 积分/充值/记录
//

import SwiftUI

struct MyView: View {
    @EnvironmentObject var userSession: UserSession
    @EnvironmentObject var pointsManager: PointsManager
    @State private var showingLogin = false
    @State private var showingRecharge = false
    @State private var showingDownloads = false
    @State private var showingHistory = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.95, green: 0.95, blue: 0.97)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // 用户信息区域
                        UserInfoSection()
                            .environmentObject(userSession)
                            .environmentObject(pointsManager)

                        // 积分卡片
                        PointsCard()
                            .environmentObject(pointsManager)

                        // 功能菜单列表
                        VStack(spacing: 1) {
                            MenuRow(icon: "sparkles", title: "积分充值", subtitle: "充越多省越多", showArrow: true) {
                                showingRecharge = true
                            }

                            MenuRow(icon: "photo.on.rectangle.angled", title: "我的下载", subtitle: "查看下载记录", showArrow: true) {
                                showingDownloads = true
                            }

                            MenuRow(icon: "clock.arrow.circlepath", title: "充值记录", subtitle: "查看充值明细", showArrow: true) {
                                showingHistory = true
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)

                        // 底部信息
                        VStack(spacing: 12) {
                            Button(action: {
                                // 隐私政策
                            }) {
                                Text("隐私政策")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }

                            Button(action: {
                                // 用户协议
                            }) {
                                Text("用户协议")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }

                            Text("版本 1.0.0")
                                .font(.system(size: 12))
                                .foregroundColor(.tertiary)
                        }
                        .padding(.top, 20)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("我的")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingLogin) {
            LoginView()
                .environmentObject(userSession)
        }
        .sheet(isPresented: $showingRecharge) {
            RechargeView()
                .environmentObject(pointsManager)
        }
        .sheet(isPresented: $showingDownloads) {
            DownloadsView()
        }
        .sheet(isPresented: $showingHistory) {
            RechargeHistoryView()
                .environmentObject(pointsManager)
        }
    }
}

// 用户信息区域
struct UserInfoSection: View {
    @EnvironmentObject var userSession: UserSession

    var body: some View {
        HStack(spacing: 16) {
            // 头像
            Circle()
                .fill(LinearGradient(
                    colors: [Color.blue.opacity(0.8), Color.blue.opacity(0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 70, height: 70)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                )

            // 用户信息
            VStack(alignment: .leading, spacing: 6) {
                if userSession.isLoggedIn {
                    Text("欢迎回来")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)

                    Text(userSession.phoneNumber.isEmpty ? "用户" : userSession.phoneNumber)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.primary)
                } else {
                    Text("未登录")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.primary)

                    Text("登录后享受更多功能")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // 登录/退出按钮
            if userSession.isLoggedIn {
                Button(action: {
                    userSession.logout()
                }) {
                    Text("退出登录")
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// 积分卡片
struct PointsCard: View {
    @EnvironmentObject var pointsManager: PointsManager

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("当前积分")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.9))

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(pointsManager.currentPoints)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)

                        Text("积分")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }

                Spacer()

                Image(systemName: "sparkles")
                    .font(.system(size: 40))
                    .foregroundColor(.white.opacity(0.3))
            }

            Divider()
                .background(Color.white.opacity(0.3))

            HStack(spacing: 30) {
                VStack(spacing: 4) {
                    Text("下载消耗")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))

                    Text("100积分/张")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }

                VStack(spacing: 4) {
                    Text("可下载数")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))

                    Text("\(pointsManager.currentPoints / 100)张")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.3, green: 0.5, blue: 1.0),
                    Color(red: 0.5, green: 0.3, blue: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

// 菜单行
struct MenuRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let showArrow: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
                    .frame(width: 40, height: 40)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16))
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }

                Spacer()

                if showArrow {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.tertiary)
                }
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MyView()
        .environmentObject(UserSession())
        .environmentObject(PointsManager())
}
