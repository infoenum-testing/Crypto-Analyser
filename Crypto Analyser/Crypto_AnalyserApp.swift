//
//  Crypto_AnalyserApp.swift
//  Crypto Analyser
//
//  Created by IE15 on 20/12/24.
//

import SwiftUI

@main
struct Crypto_AnalyserApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @ObservedObject var router = Router()
    @State var isUserLoggedIn = UserSessionManager.isUserLoggedIn()
    @State private var isLoggedIn = true
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.authNavigationPath) {
                ZStack {
                    if !isLoggedIn || !isUserLoggedIn {
                        LoginView()
                        
                    } else {
                        TabbarView()
                    }
                } .navigationDestination(for: Router.AuthDestination.self) { destination in
                    switch destination {
                    case .signUp:
                        SignUpView()
                            .navigationBarBackButtonHidden()
                    case .logIn:
                        LoginView()
                            .navigationBarBackButtonHidden()
                    case .forgotPassword:
                        ForgotPassword()
                            .navigationBarBackButtonHidden()
                    case .tabBar:
                        TabbarView()
                            .navigationBarBackButtonHidden()
                    case .accountInformation:
                        AccountInformationView()
                            .navigationBarBackButtonHidden()
                    case .editProfile:
                        EditProfileView()
                            .navigationBarBackButtonHidden()
                    case .searchView:
                        SearchView()
                            .navigationBarBackButtonHidden()
                    case .imageAnalyser(let image):
                         ImageAnalyserView(image: image)
                            .navigationBarBackButtonHidden()
                    }
                }
            }
            .navigationBarBackButtonHidden()
            .environmentObject(router)
            .onAppear {
#if Pro
                print("Production")
#else
                print("Development")
#endif
            }
            .onAppear {
                NotificationCenter.default.addObserver(forName: .userDidLogout, object: nil, queue: .main) { _ in
                    isLoggedIn = false
                }
            }
        }
    }
}

extension Notification.Name {
    static let userDidLogout = Notification.Name("userDidLogout")
}
