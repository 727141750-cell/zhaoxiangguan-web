//
//  ZhaoXiangGuanApp.swift
//  ZhaoXiangGuan
//
//  Created on 2025-12-30.
//

import SwiftUI

@main
struct ZhaoXiangGuanApp: App {
    @StateObject private var userSession = UserSession()
    @StateObject private var pointsManager = PointsManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userSession)
                .environmentObject(pointsManager)
                .onAppear {
                    // 首次启动检查
                    checkFirstLaunch()
                }
        }
    }

    private func checkFirstLaunch() {
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        if !hasLaunchedBefore {
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            // 首次启动赠送100积分
            pointsManager.addPoints(100)
            UserDefaults.standard.set(true, forKey: "hasReceivedInitialPoints")
        }
    }
}
