//
//  GoogleSignInManager.swift
//  Crypto Analyser Dev
//
//  Created by IE15 on 21/12/24.
//


import FirebaseCore
import FirebaseAuth
import SwiftUI
import Firebase
import GoogleSignIn

class GoogleSignInManager {
    static let shared = GoogleSignInManager()
    var user: User? // Firebase User
    var isSignedIn: Bool = false
    let db = Firestore.firestore()
    
    
    func signInWithGoogle(completion: @escaping (Result<(String, String), Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Get the root UIViewController.
        guard let rootViewController = getRootViewController() else {
            print("Unable to get the root view controller.")
            return
        }
        
        // Start the sign-in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [unowned self] result, error in
            guard error == nil else {
                print("Error during Google Sign-In: \(error!.localizedDescription)")
                completion(.failure(NSError(domain: "AppDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Cancel"])))
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                print("Failed to get user or ID token.")
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            // Use the credential to authenticate with Firebase
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase Sign-In failed: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let user = authResult?.user else {
                    print("No user found after sign-in.")
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user found."])))
                    return
                }
                
                // Extract user information (e.g., name, email) from the Firebase user
                let name = user.displayName ?? "Unknown"  // Optional, might be nil
                let email = user.email ?? "No email"     // Optional, might be nil
                let trail = 0
                self.db.collection("users").document(email).setData([
                    "Trial": trail,
                    "name": name,
                    "uid": user.uid
                ]) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success((name, email)))
                    }
                }
            }
        }
    }
    
    func getRootViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return nil
        }
        return rootViewController
    }
    
    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            print("No authenticated user found.")
            completion(.failure(NSError(domain: "DeleteAccount", code: 404, userInfo: [NSLocalizedDescriptionKey: "No authenticated user found."])))
            return
        }
        
        user.delete { error in
            if let error = error {
                print("Error deleting user: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            let email = UserSessionManager.getUserData().email.lowercased() 
            print(email)
            Firestore.firestore().collection("users").document(email).delete { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                user.delete { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            }
        }
    }
}
