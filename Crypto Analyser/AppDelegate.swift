//
//  AppDelegate.swift
//  Crypto Analyser
//
//  Created by IE15 on 21/12/24.
//

import Foundation
import SwiftUI
import FirebaseCore
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    //YOU CAN ADD OTHER UIApplicationDelegate here
    func application(
            _ app: UIApplication,
            open url: URL,
            options: [UIApplication.OpenURLOptionsKey : Any] = [:]
        ) -> Bool {
            return GIDSignIn.sharedInstance.handle(url)
        }
}
