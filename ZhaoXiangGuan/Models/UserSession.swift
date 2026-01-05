//
//  UserSession.swift
//  ZhaoXiangGuan
//
//  用户会话管理
//

import Foundation
import Combine

class UserSession: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var phoneNumber: String = ""
    @Published var userID: String = ""

    private let isLoggedInKey = "user_is_logged_in"
    private let phoneNumberKey = "user_phone_number"
    private let userIDKey = "user_id"

    init() {
        loadUserSession()
    }

    // 登录
    func login(phone: String) {
        self.phoneNumber = phone
        self.userID = UUID().uuidString
        self.isLoggedIn = true
        saveUserSession()
    }

    // 第三方登录
    func loginWithThirdParty(provider: String, userID: String) {
        self.phoneNumber = ""
        self.userID = userID
        self.isLoggedIn = true
        saveUserSession()
    }

    // 登出
    func logout() {
        self.phoneNumber = ""
        self.userID = ""
        self.isLoggedIn = false
        UserDefaults.standard.removeObject(forKey: isLoggedInKey)
        UserDefaults.standard.removeObject(forKey: phoneNumberKey)
        UserDefaults.standard.removeObject(forKey: userIDKey)
    }

    // 保存会话
    private func saveUserSession() {
        UserDefaults.standard.set(isLoggedIn, forKey: isLoggedInKey)
        UserDefaults.standard.set(phoneNumber, forKey: phoneNumberKey)
        UserDefaults.standard.set(userID, forKey: userIDKey)
    }

    // 加载会话
    private func loadUserSession() {
        self.isLoggedIn = UserDefaults.standard.bool(forKey: isLoggedInKey)
        self.phoneNumber = UserDefaults.standard.string(forKey: phoneNumberKey) ?? ""
        self.userID = UserDefaults.standard.string(forKey: userIDKey) ?? ""
    }
}
