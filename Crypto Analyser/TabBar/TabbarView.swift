//
//  TabbarView.swift
//  Crypto Analyser
//
//  Created by IE15 on 21/12/24.
//

import SwiftUI

struct TabbarView: View {
    @EnvironmentObject var router: Router
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            
            CryptoNewsView()
                .tabItem {
                    Label("News", systemImage: "newspaper")
                }
            
            
            SettingView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .tint(Color.midnightBlue)
        .onAppear(perform: {
            UITabBar.appearance().unselectedItemTintColor = .gray
            
            UITabBar.appearance().backgroundColor = .systemGray4.withAlphaComponent(0.3)
            
            UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.systemPink]
        })
    }
}

#Preview {
    TabbarView()
}
