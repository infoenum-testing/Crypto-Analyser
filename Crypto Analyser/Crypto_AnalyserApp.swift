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
    @StateObject private var entitlementManager: EntitlementManager
    @StateObject private var subscriptionsManager: SubscriptionsManager
    init() {
        let entitlementManager = EntitlementManager()
        let subscriptionsManager = SubscriptionsManager(entitlementManager: entitlementManager)
        
        self._entitlementManager = StateObject(wrappedValue: entitlementManager)
        self._subscriptionsManager = StateObject(wrappedValue: subscriptionsManager)
    }
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
                            .navigationBarHidden(true)
                    case .logIn:
                        LoginView()
                            .navigationBarBackButtonHidden()
                            .navigationBarHidden(true)
                    case .forgotPassword:
                        ForgotPassword()
                            .navigationBarBackButtonHidden()
                            .navigationBarHidden(true)
                    case .tabBar:
                        TabbarView()
                            .navigationBarBackButtonHidden()
                            .navigationBarHidden(true)
                    case .accountInformation:
                        AccountInformationView()
                            .navigationBarBackButtonHidden()
                            .navigationBarHidden(true)
                    case .editProfile:
                        EditProfileView()
                            .navigationBarBackButtonHidden()
                            .navigationBarHidden(true)
                    case .searchView:
                        SearchView()
                            .navigationBarBackButtonHidden()
                            .navigationBarHidden(true)
                    case .imageAnalyser(let image,let fromSearch):
                        ImageAnalyserView(fromSearch: fromSearch, image: image)
                            .navigationBarBackButtonHidden()
                            .navigationBarHidden(true)
                    case .dataDescription(image:let image,afterAnalyse: let afterAnalyse,title: let title, message: let message):
                        DataDescriptionView(image:image,afterAnalyse: afterAnalyse, title: title, message: message)
                            .navigationBarBackButtonHidden()
                            .navigationBarHidden(true)
                    case .subscription:
                        SubscriptionsView()
                            .navigationBarBackButtonHidden()
                            .navigationBarHidden(true)
                    }
                }
            }
            .navigationBarBackButtonHidden()
            .environmentObject(router)
            .environmentObject(entitlementManager)
            .environmentObject(subscriptionsManager)
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
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button(action: {
                            KeyboardUtility.hideKeyboard()
                        }, label: {
                            Text("Done")
                                .foregroundStyle(.blue)
                                .font(.system(size: 18, weight: .regular))
                        })
                    }
                }
            }
            .task {
                await subscriptionsManager.updatePurchasedProducts()
            }
        }
    }
}

extension Notification.Name {
    static let userDidLogout = Notification.Name("userDidLogout")
}
