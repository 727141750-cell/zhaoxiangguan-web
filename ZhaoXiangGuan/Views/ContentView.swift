//
//  ContentView.swift
//  ZhaoXiangGuan
//
//  主界面 - 包含底部导航栏
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("首页", systemImage: selectedTab == 0 ? "house.fill" : "house")
                }
                .tag(0)

            StyleGalleryView()
                .tabItem {
                    Label("风格", systemImage: selectedTab == 1 ? "photo.fill" : "photo")
                }
                .tag(1)

            MyView()
                .tabItem {
                    Label("我的", systemImage: selectedTab == 2 ? "person.fill" : "person")
                }
                .tag(2)
        }
        .accentColor(.primary)
    }
}

#Preview {
    ContentView()
}
