//
//  FirebaseAuthentication.swift
//  Crypto Analyser Dev
//
//  Created by IE15 on 21/12/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

class FirebaseAuthentication {
    static let shared = FirebaseAuthentication()
    let db = Firestore.firestore()
    
    func registerUser(email: String, password: String, name: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = authResult?.user else {
                completion(.failure(NSError(domain: "FirebaseAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create user"])))
                return
            }
            
            let userEmail = user.email ?? ""
            self.db.collection("users").document(userEmail).setData([
                "name": name,
                "uid": user.uid
            ]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    UserSessionManager.saveUserData(name: name, email: userEmail)
                    completion(.success(()))
                }
            }
        }
        
    }
    
    
    
    func deleteUser(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "FirebaseAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Log in Again"])))
            return
        }
        user.delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                deleteFromDataBase()
            }
        }
        func deleteFromDataBase() {
            let userEmail = user.email ?? ""
            db.collection("users").document(userEmail).delete { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(()))
            }
        }
    }
    
    func loginUser(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) {
            result, err in
            if let err = err {
                print ("Failed to login user:", err)
                completion(.failure(err))
            } else {
                print(email)
                self.fetchUserName(uid: email.lowercased()) { result in
                    switch result {
                    case .success(let name):
                        print("User logged in with name: \(name)")
                        UserSessionManager.saveUserData(name: name, email: email)
                        completion(.success(()))
                    case .failure(let error):
                        print("Failed to fetch username: \(error.localizedDescription)")
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    func fetchUserName(uid: String, completion: @escaping (Result<String, Error>) -> Void) {
        db.collection("users").document(uid).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let document = document, document.exists, let data = document.data() {
                if let name = data["name"] as? String {
                    completion(.success(name))
                } else {
                    completion(.failure(NSError(domain: "Firestore", code: -1, userInfo: [NSLocalizedDescriptionKey: "Name not found in Firestore"])))
                }
            } else {
                completion(.failure(NSError(domain: "Firestore", code: -1, userInfo: [NSLocalizedDescriptionKey: "User data not found"])))
            }
        }
    }
    
    func forgotPassword(email: String, completion: @escaping (Result<String, Error>) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success("A password reset email has been sent to \(email)."))
            }
        }
    }
    
    func updateUserName(email: String, newName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Reference the document directly using the email as the document ID
        db.collection("users").document(email).updateData(["name": newName]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func updateTrial(email: String, trail: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        // Reference the document directly using the email as the document ID
        db.collection("users").document(email).updateData(["Trial": trail]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func getTrial(email: String, completion: @escaping (Result<Int, Error>) -> Void) {
        let docRef = db.collection("users").document(email)
        
        docRef.getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let document = document, document.exists {
                if let trial = document.data()?["Trial"] as? Int {
                    completion(.success(trial))
                } else {
                    completion(.failure(NSError(domain: "Firestore", code: -1, userInfo: [NSLocalizedDescriptionKey: "Trial field not found or invalid"])))
                }
            } else {
                completion(.failure(NSError(domain: "Firestore", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document does not exist"])))
            }
        }
    }
}

struct SearchDetails {
    let id:String
    let image: UIImage?
    let title: String
    let message: String
    let date: Date
}
