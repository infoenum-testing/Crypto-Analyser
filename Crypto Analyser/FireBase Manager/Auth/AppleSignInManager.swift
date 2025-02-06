//
//  AppleSignInManager.swift
//  Crypto Analyser
//
//  Created by IE15 on 23/12/24.
//
import Foundation
import FirebaseFirestore
import AuthenticationServices
import FirebaseAuth
import CryptoKit

final class FirebaseAppleLoginViewModel: NSObject,ObservableObject {
    
    static let shared = FirebaseAppleLoginViewModel()
    private var currentNonce: String?
    private var completion: ((Result<AuthDataResult, Error>) -> Void)?
    
    private var contextProvider: AuthorizationContextProvider?
    
    private final class AuthorizationContextProvider: NSObject, ASAuthorizationControllerPresentationContextProviding {
        
        weak var contextController: UIViewController?
        
        static var keyWindow: UIWindow? {
            let keyWindow: UIWindow?
            keyWindow = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first(where: { $0.isKeyWindow })
            
            return keyWindow
        }
        
        init(controller: UIViewController) {
            self.contextController = controller
        }
        func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
            return contextController?.view.window ?? Self.keyWindow!
        }
    }
    
    
    
    func login(completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        request.nonce = sha256(nonce)
        
        guard let rootviewController = UIApplication.shared.keyWindow?.rootViewController else {
            return
        }
        
        // Create the context provider
        let contextProvider = AuthorizationContextProvider(controller: rootviewController)
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = contextProvider
        authorizationController.performRequests()
        
        self.completion = { [self] result in
            switch result {
            case .success(let authResult):
                // Attempt to extract name and email
                if let user = Auth.auth().currentUser {
                    var gmailID: String = ""
                    var userName: String = ""
                    if KeychainService.load(key: "username") != nil {
                        userName = KeychainService.load(key: "username") ?? ""
                        gmailID  =  KeychainService.load(key: "email") ?? ""
                    } else {
                         gmailID = user.email?.lowercased() ?? "test"
                         userName =  user.displayName ?? ""
                    }
                    
                    
                    checkAndSaveUserToFirestore(email: gmailID, name: userName, uid: user.uid) { result in
                        switch result {
                        case .success(let data):
                            if data.exists {
                                UserSessionManager.saveUserData(name: data.existingName ?? "", email: gmailID, loginBy: .apple)
                                print("User already exists in Firestore. Name: \(data.existingName ?? "No name found")")
                            } else {
                                print("New user added to Firestore.")
                                UserSessionManager.saveUserData(name: userName, email: gmailID, loginBy: .apple)
                            }
                            completion(.success(authResult))
                        case .failure(let error):
                            print("Failed to save or check user in Firestore: \(error.localizedDescription)")
                            completion(.failure(error))
                        }
                    }
                } else {
                    completion(.success(authResult))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func checkAndSaveUserToFirestore(email: String, name: String, uid: String, completion: @escaping (Result<(exists: Bool, existingName: String?), Error>) -> Void) {
        
        guard !email.isEmpty else {
               print("Error: Email cannot be empty")
               completion(.failure(NSError(domain: "FirestoreError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Email cannot be empty"])))
               return
           }
        
        let firestore = Firestore.firestore()
        let userDocument = firestore.collection("users").document(email)

        // Check if the document already exists
        userDocument.getDocument { (documentSnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let documentSnapshot = documentSnapshot, documentSnapshot.exists {
                // Document exists, retrieve the existing name
                let existingName = documentSnapshot.data()?["name"] as? String
                print("Document already exists for email: \(email). Existing name: \(existingName ?? "Unknown")")
                completion(.success((true, existingName))) // Exists with the retrieved name
            } else {
                // Document does not exist, add it to Firestore
                userDocument.setData([
                    "Trial":0,
                    "name": name,
                    "uid": uid
                ]) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        print("User added to Firestore with email: \(email)")
                        completion(.success((false, nil))) // New document added
                    }
                }
            }
        }
    }

    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

extension FirebaseAppleLoginViewModel: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        guard let completion = completion else {
            return
        }
        
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let nonce = currentNonce, let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            let error = NSError(domain: "Login", code: 0, userInfo: [NSLocalizedDescriptionKey: "somethingWentWrong"])
            completion(.failure(error))
            return
        }
        
        print("Apple ID Credential:")
               print("User ID: \(appleIDCredential.user)")
               print("Email: \(String(describing: appleIDCredential.email))")
               print("Full Name: \(String(describing: appleIDCredential.fullName))")
               print("Identity Token: \(idTokenString)")

               // Use relay email if the actual email is nil
        if let email = appleIDCredential.email  {
            
        
               let userName = appleIDCredential.fullName?.givenName ?? "User"

        if KeychainService.load(key: "username") == nil {
                    // Save to Keychain if not already present
                    if KeychainService.save(key: "username", data: userName) {
                        print("Username saved to Keychain.")
                    } else {
                        print("Failed to save username to Keychain.")
                    }
                    
                    if KeychainService.save(key: "email", data: email) {
                        print("Email saved to Keychain.")
                    } else {
                        print("Failed to save email to Keychain.")
                    }
                } else {
                    print("Credentials already exist in Keychain.")
                }
        
        }
        
        // Initialize a Firebase credential.
        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                  idToken: idTokenString,
                                                  rawNonce: nonce)
        signIn(credential: credential, completion: completion)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        guard let completion = completion else {
            return
        }
        
        if let authorizationError = error as? ASAuthorizationError {
            switch authorizationError.code {
            case .canceled:
                completion(.failure(NSError(domain: "AppDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Cancel"])))
                return
            default:
                break
            }
        }
        completion(.failure(error))
    }
    
    func signIn(credential: AuthCredential, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        Auth.auth().signIn(with: credential, completion: { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else if let authResult = authResult {
                
                completion(.success(authResult))
            } else {
                let error = NSError(domain: "Login", code: 0, userInfo: [NSLocalizedDescriptionKey: "somethingWentWrong"])
                completion(.failure(error))
            }
        })
    }
}
