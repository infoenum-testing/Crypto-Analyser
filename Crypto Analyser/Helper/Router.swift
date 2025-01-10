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
        case imageAnalyser(image: UIImage,fromSearch: Bool)
        case dataDescription(image: UIImage,afterAnalyse:Bool,title: String?, message: String)

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
            case .imageAnalyser(let image,let fromSearch):
                hasher.combine(image.pngData()?.hashValue ?? 0)
                hasher.combine(fromSearch)
            case .dataDescription(let image,let afterAnalyse, let title, let message):
                hasher.combine(image.pngData()?.hashValue ?? 0)
                hasher.combine(afterAnalyse)
                hasher.combine(title)
                hasher.combine(message)
            }
        }

        public static func == (lhs: AuthDestination, rhs: AuthDestination) -> Bool {
            switch (lhs, rhs) {
            case (.signUp, .signUp),
                 (.logIn, .logIn),
                 (.forgotPassword, .forgotPassword),
                 (.tabBar, .tabBar),
                 (.accountInformation, .accountInformation),
                 (.editProfile, .editProfile),
                 (.searchView, .searchView):
                return true
            case (.imageAnalyser(let lhsImage,let lhsFromSearch), .imageAnalyser(let rhsImage,let rhsFromSearch)):
                return lhsImage.pngData() == rhsImage.pngData()  &&
                lhsFromSearch == rhsFromSearch
            case (.dataDescription(let lhsImage,let lhsAfterAnalyse, let lhsTitle, let lhsMessage),
                  .dataDescription(let rhsImage,let rhsAfterAnalyse,let rhsTitle, let rhsMessage)):
                return lhsImage.pngData() == rhsImage.pngData()  &&
                       lhsAfterAnalyse == rhsAfterAnalyse &&
                       lhsTitle == rhsTitle &&
                       lhsMessage == rhsMessage
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

    func navigateBackInAuth(count:Int = 1) {
          for _ in 0..<count {
                if !authNavigationPath.isEmpty {
                    authNavigationPath.removeLast()
                } else {
                    break // Stop if the path is already empty
                }
            }
    }
    
    func navigateToAuthRoot() {
        authNavigationPath.removeLast(authNavigationPath.count)
    }
}
