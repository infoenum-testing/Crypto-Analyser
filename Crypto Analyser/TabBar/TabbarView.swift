//
//  TabbarView.swift
//  Crypto Analyser
//
//  Created by IE15 on 21/12/24.
//

import SwiftUI

struct TabbarView: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var subscriptionsManager: SubscriptionsManager
    var body: some View {
        let _ = Self._printChanges()
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                . task {
                    await subscriptionsManager.updatePurchasedProducts()
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
        .tint(Color.bordercolor)
        .onAppear(perform: {
            let appearance = UITabBarAppearance()
                        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
                        appearance.backgroundColor = UIColor(Color.cellcolor)
                        
                        // Use this appearance when scrolling behind the TabView:
                        UITabBar.appearance().standardAppearance = appearance
                        // Use this appearance when scrolled all the way up:
                        UITabBar.appearance().scrollEdgeAppearance = appearance
        })
    }
}

#Preview {
    TabbarView()
}
