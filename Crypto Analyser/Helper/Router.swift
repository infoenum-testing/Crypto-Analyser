//
//  Router.swift
//  Crypto Analyser
//
//  Created by IE15 on 20/12/24.
//

//import SwiftUI
//
//final class Router: ObservableObject {
//    
//    // Define separate destinations for each flow
//    public enum AuthDestination: Codable, Hashable {
//        case signUp
//        case logIn
//        case forgotPassword
//        case tabBar
//        case accountInformation
//        case editProfile
//        case searchView
//        case imageAnalyser(image: UIImage)
//        
//    }
//
//    // Separate navigation paths for each flow
//    @Published var authNavigationPath = NavigationPath()
//
//    // MARK: - Auth Navigation
//    func navigateToAuth(_ destination: AuthDestination) {
//        authNavigationPath.append(destination)
//    }
//    
//    func navigateBackInAuth() {
//        if !authNavigationPath.isEmpty {
//            authNavigationPath.removeLast()
//        }
//    }
//    
//    func navigateToAuthRoot() {
//        authNavigationPath.removeLast(authNavigationPath.count)
//    }
//   
//}
import SwiftUI

final class Router: ObservableObject {
    // Define destinations for the authentication flow
    public enum AuthDestination: Hashable {
        case signUp
        case logIn
        case forgotPassword
        case tabBar
        case accountInformation
        case editProfile
        case searchView
        case imageAnalyser(image: UIImage)

        // Custom hashable implementation
        func hash(into hasher: inout Hasher) {
            switch self {
            case .signUp:
                hasher.combine("signUp")
            case .logIn:
                hasher.combine("logIn")
            case .forgotPassword:
                hasher.combine("forgotPassword")
            case .tabBar:
                hasher.combine("tabBar")
            case .accountInformation:
                hasher.combine("accountInformation")
            case .editProfile:
                hasher.combine("editProfile")
            case .searchView:
                hasher.combine("searchView")
            case .imageAnalyser(let image):
                hasher.combine(image.hashValue)
            }
        }

        static func == (lhs: AuthDestination, rhs: AuthDestination) -> Bool {
            switch (lhs, rhs) {
            case (.signUp, .signUp),
                 (.logIn, .logIn),
                 (.forgotPassword, .forgotPassword),
                 (.tabBar, .tabBar),
                 (.accountInformation, .accountInformation),
                 (.editProfile, .editProfile),
                 (.searchView, .searchView):
                return true
            case (.imageAnalyser(let lhsImage), .imageAnalyser(let rhsImage)):
                return lhsImage.isEqual(rhsImage)
            default:
                return false
            }
        }
    }

    // Navigation path for auth
    @Published var authNavigationPath = NavigationPath()

    // MARK: - Navigation Actions
    func navigateToAuth(_ destination: AuthDestination) {
        authNavigationPath.append(destination)
    }

    func navigateBackInAuth() {
        if !authNavigationPath.isEmpty {
            authNavigationPath.removeLast()
        }
    }

    func navigateToAuthRoot() {
        authNavigationPath.removeLast(authNavigationPath.count)
    }
}
