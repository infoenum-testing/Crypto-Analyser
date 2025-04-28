//
//  SettingView.swift
//  Crypto Analyser
//
//  Created by IE15 on 21/12/24.
//

import SwiftUI
import StoreKit

struct SettingView: View {
    enum AlertType {
        case logout
        case delete
        case resetPassword
    }
    
    @EnvironmentObject var router: Router
    @State private var alertType: AlertType = .logout
    @State private var isDeleteAccount: Bool = false
    @State private var alert = false
    @State private var errorAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var alertButtonText = ""
    
    @StateObject private var borderAnimationViewModel = BorderAnimationViewModel()
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                Text(StringConstants.setting)
                    .foregroundStyle(.white)
                    .font(.system(size: 25, weight: .semibold))
                    .padding(.leading,20)
                
                ScrollView(showsIndicators:false) {
                    VStack {
                        HStack(spacing:5) {
                            VStack(alignment: .leading) {
                                let name = UserSessionManager.getUserData().name
                                Text(name)
                                    .foregroundColor(.white)
                                    .font(.system(size: 22, weight: .semibold))
                                    .padding(.leading)
                                let gmail = UserSessionManager.getUserData().email
                                Text(gmail)
                                    .foregroundColor(.white)
                                    .font(.system(size: 14, weight: .semibold))
                                    .padding(.leading)
                                
                            }
                            Spacer()
                        }
                        .frame(height: 100)
                        .background(Color.themecolorprimary)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(LinearGradient(
                                    gradient: Gradient(colors: borderAnimationViewModel.gradientColors),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ), lineWidth: 4)
                                .blur(radius: 2)
                        )
                        .onAppear {borderAnimationViewModel.startColorAnimation()}
                        .onDisappear {borderAnimationViewModel.stopColorAnimation()}
                        .padding(.top,5)
                        
                        VStack(alignment: .leading,spacing:5) {
                            Text(StringConstants.account)
                                .foregroundColor(.white)
                                .font(.system(size: 22, weight: .semibold))
                            
                            CommonCell(title: StringConstants.editProfile,action: {
                                router.navigateToAuth(.editProfile)
                            })
                            if UserSessionManager.getUserData().loginBy == .gmail {
                                CommonCell(title: StringConstants.resetPassword,action: {
                                    alertType  = .resetPassword
                                    alert = true
                                    alertTitle = StringConstants.resetPassword
                                    alertMessage = "\(StringConstants.resetPasswordDes) \(UserSessionManager.getUserData().email )."
                                    alertButtonText = StringConstants.sendEmail
                                })
                            }
                            CommonCell(title: StringConstants.subscriptions,action: {
                                router.navigateToAuth(.subscription)
                            })
                        }
                        .padding(.top,5)
                        
                        VStack(alignment: .leading,spacing:5) {
                            Text(StringConstants.privacy)
                                .foregroundColor(.white)
                                .font(.system(size: 22, weight: .semibold))
                            
                            CommonCell(title: StringConstants.privacyPolicy,action: {
                                if let url = URL(string: StringConstants.privacyPolicyURL) {
                                    UIApplication.shared.open(url)
                                }
                            })
                            
                            CommonCell(title: StringConstants.termsAndConditions,action: {
                                if let url = URL(string: StringConstants.privacyPolicyURL) {
                                    UIApplication.shared.open(url)
                                }
                            })
                            
                            CommonCell(title: StringConstants.helpAndSupport,action: {
                                if let url = URL(string: StringConstants.privacyPolicyURL) {
                                    UIApplication.shared.open(url)
                                }
                            })
                        }
                        .padding(.top)
                        
                        VStack(alignment: .leading,spacing:5) {
                            Text(StringConstants.securityOptions)
                                .foregroundColor(.white)
                                .font(.system(size: 22, weight: .semibold))
                            CommonCell(title: StringConstants.logout,action: {
                                alertType  = .logout
                                alert = true
                                alertTitle = StringConstants.confirmLogout
                                alertMessage = StringConstants.logoutDes
                                alertButtonText = StringConstants.logout
                            })
                            
                            CommonCell(title: StringConstants.deleteAccount,textColor:.red,isLoading:isDeleteAccount,action: {
                                alertType  = .delete
                                alert = true
                                alertTitle = StringConstants.deleteAccount
                                alertMessage = StringConstants.deleteAccountDes
                                alertButtonText = StringConstants.delete
                            })
                        }
                        .padding(.top)
                    }
                    .padding(.horizontal,20)
                    .alert(isPresented: $errorAlert) {
                        Alert(title: Text(StringConstants.validationErrorTitle), message: Text(alertMessage), dismissButton: .default(Text(StringConstants.oKText)))
                    }
                }
            }
            .background(Color.themecolorprimary)
            .alert(alertTitle, isPresented: $alert) {
                if alertType == .logout {
                    Button(StringConstants.cancel, role: .cancel) {}
                    Button(alertButtonText, role: .destructive) {
                        router.navigateToAuthRoot()
                        UserSessionManager.clearUserData()
                    }
                } else if alertType == .delete {
                    Button(StringConstants.cancel, role: .cancel) {}
                    Button(alertButtonText, role: .destructive) {
                        deleteAccount()
                    }
                } else if alertType == .resetPassword {
                    Button(StringConstants.cancel, role: .cancel) {}
                    Button(StringConstants.sendEmail, action: {
                        let email = UserSessionManager.getUserData().email
                        FirebaseAuthentication.shared.forgotPassword(email: email) { result in
                            switch result {
                            case .success(_):
                                print("Success")
                            case .failure(let error):
                                print(error)
                            }
                        }
                    })
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func CommonCell(title: String,textColor:Color = .white, placeholder: String = "Type here", isLoading:Bool = false,action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundStyle(textColor)
                    .padding()
                Spacer()
                if isLoading {
                    ProgressView()
                        .tint(.pink)
                        .frame(width: 15, height: 20)
                        .padding(.trailing)
                } else {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .frame(width: 15, height: 20)
                        .padding()
                }
            }
            .frame(height: 50)
            .background(Color.cellcolortheme)
            .cornerRadius(8)
            .accentColor(.black)
            .foregroundColor(.black)
            .font(.system(size: 20))
            .padding(.bottom)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    func deleteAccount() {
        isDeleteAccount = true
        FirebaseAuthentication.shared.deleteUser { result in
            isDeleteAccount = false
            switch result {
            case .success():
                router.navigateToAuthRoot()
                UserSessionManager.clearUserData()
            case .failure(let error):
                errorAlert = true
                alertMessage = error.localizedDescription
                router.navigateToAuthRoot()
                UserSessionManager.clearUserData()
            }
        }
        
    }
}

#Preview {
    SettingView()
}

