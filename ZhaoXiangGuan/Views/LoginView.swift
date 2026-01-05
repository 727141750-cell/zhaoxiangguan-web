//
//  LoginView.swift
//  ZhaoXiangGuan
//
//  登录注册页面
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var userSession: UserSession
    @Environment(\.dismiss) var dismiss
    @State private var phoneNumber = ""
    @State private var verificationCode = ""
    @State private var isSendingCode = false
    @State private var countdown = 0
    @State private var showSuccess = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.95, green: 0.95, blue: 0.97)
                    .ignoresSafeArea()

                VStack(spacing: 30) {
                    Spacer()
                        .frame(height: 40)

                    // 标题
                    VStack(spacing: 12) {
                        Image(systemName: "camera.metering.matrix")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)

                        Text("造像馆")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.primary)

                        Text("登录后领取100积分")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }

                    // 登录表单
                    VStack(spacing: 20) {
                        // 手机号输入
                        HStack {
                            Image(systemName: "iphone")
                                .foregroundColor(.secondary)

                            TextField("请输入手机号", text: $phoneNumber)
                                .keyboardType(.phonePad)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )

                        // 验证码输入
                        HStack {
                            Image(systemName: "lock.shield")
                                .foregroundColor(.secondary)

                            TextField("请输入验证码", text: $verificationCode)
                                .keyboardType(.numberPad)

                            Spacer()

                            Button(action: sendVerificationCode) {
                                Text(countdown > 0 ? "\(countdown)s" : "获取验证码")
                                    .font(.system(size: 14))
                                    .foregroundColor(countdown > 0 ? .secondary : .blue)
                            }
                            .disabled(countdown > 0 || isSendingCode)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 30)

                    // 登录按钮
                    Button(action: login) {
                        Text("登录 / 注册")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                LinearGradient(
                                    colors: [Color.blue, Color.blue.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(27)
                    }
                    .padding(.horizontal, 30)
                    .disabled(!isValidInput)
                    .opacity(isValidInput ? 1 : 0.6)

                    // 第三方登录
                    VStack(spacing: 20) {
                        HStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)

                            Text("其他登录方式")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)

                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                        }
                        .padding(.horizontal, 40)

                        HStack(spacing: 40) {
                            ThirdPartyLoginButton(icon: "wechat.logo.fill", title: "微信") {
                                loginWithThirdParty("WeChat")
                            }

                            ThirdPartyLoginButton(icon: "applelogo", title: "Apple ID") {
                                loginWithThirdParty("Apple")
                            }
                        }
                    }

                    Spacer()

                    // 底部协议
                    HStack(spacing: 4) {
                        Text("登录即表示同意")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)

                        Button(action: {}) {
                            Text("《用户协议》")
                                .font(.system(size: 12))
                                .foregroundColor(.blue)
                        }

                        Text("和")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)

                        Button(action: {}) {
                            Text("《隐私政策》")
                                .font(.system(size: 12))
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
        .alert("登录成功", isPresented: $showSuccess) {
            Button("确定") {
                dismiss()
            }
        } message: {
            Text("欢迎来到造像馆！")
        }
    }

    private var isValidInput: Bool {
        return phoneNumber.count == 11 && verificationCode.count >= 4
    }

    private func sendVerificationCode() {
        isSendingCode = true

        // 模拟发送验证码
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isSendingCode = false
            countdown = 60
            startCountdown()
        }
    }

    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            countdown -= 1
            if countdown <= 0 {
                timer.invalidate()
            }
        }
    }

    private func login() {
        // 模拟登录
        userSession.login(phone: phoneNumber)
        showSuccess = true
    }

    private func loginWithThirdParty(_ provider: String) {
        userSession.loginWithThirdParty(provider: provider, userID: UUID().uuidString)
        dismiss()
    }
}

// 第三方登录按钮
struct ThirdPartyLoginButton: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 28))

                Text(title)
                    .font(.system(size: 13))
            }
            .foregroundColor(.primary)
            .frame(width: 80, height: 80)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(UserSession())
}
