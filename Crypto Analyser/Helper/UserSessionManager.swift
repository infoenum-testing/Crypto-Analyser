//
//  UserSessionManager.swift
//  Crypto Analyser
//
//  Created by IE15 on 21/12/24.
//

import Foundation

class UserSessionManager {
    private enum Keys {
        static let userName = "userName"
        static let userEmail = "userEmail"
        static let isLoggedIn = "isLoggedIn"
        static let userSubscriptionData = "userSubscriptionData"
    }
    
    // Save user data to UserDefaults
    static func saveUserData(name: String, email: String) {
        UserDefaults.standard.set(name, forKey: Keys.userName)
        UserDefaults.standard.set(email, forKey: Keys.userEmail)
        UserDefaults.standard.set(true, forKey: Keys.isLoggedIn)  // Set login status to true
    }
    
    // Get user data from UserDefaults
    static func getUserData() -> (name: String, email: String) {
        let name = UserDefaults.standard.string(forKey: Keys.userName) ?? ""
        let email = UserDefaults.standard.string(forKey: Keys.userEmail) ?? ""
        return (name, email)
    }
    
    static func getUserEmail() -> (String) {
        let email = UserDefaults.standard.string(forKey: Keys.userEmail) ?? ""
        return (email)
    }
    
    
    // Check if user is logged in
    static func isUserLoggedIn() -> Bool {
        return UserDefaults.standard.bool(forKey: Keys.isLoggedIn)
    }
    
    // Clear user data (log out)
    static func clearUserData() {
        UserDefaults.standard.set("", forKey: Keys.userName)
        UserDefaults.standard.set("test", forKey: Keys.userEmail)
        UserDefaults.standard.set(false, forKey: Keys.isLoggedIn)
        NotificationCenter.default.post(name: .userDidLogout, object: nil)
    }
    
    // Save the subscription details got from firebase
    static func saveUserSubscriptionDetail(_ user: SubscriptionPayload) {
        let encoder = JSONEncoder()
        if let encodedUser = try? encoder.encode(user) {
            UserDefaults.standard.set(encodedUser, forKey: Keys.userSubscriptionData)
        }
    }
    // To get  the subscription details saved previously
    static func getUserSubscriptionDetail() -> SubscriptionPayload? {
        if let savedUserData = UserDefaults.standard.data(forKey: Keys.userSubscriptionData) {
            let decoder = JSONDecoder()
            if let user = try? decoder.decode(SubscriptionPayload.self, from: savedUserData) {
                return user
            }
        }
        return nil
    }
    
}
