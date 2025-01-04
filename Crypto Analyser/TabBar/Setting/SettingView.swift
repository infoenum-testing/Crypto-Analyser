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
    @State private var alert = false
    @State private var errorAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var alertButtonText = ""
    
    
    
    
    
    var body: some View {
        ZStack {
            VStack {
                Text(StringConstants.setting)
                    .font(.system(size: 30, weight: .semibold))
                
                ScrollView(showsIndicators:false) {
                    VStack {
                        HStack(spacing:5) {
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                                .frame(width: 80,height: 80)
                                .padding(.leading)
                            VStack(alignment: .leading) {
                                let name = UserSessionManager.getUserData().name 
                                Text(name)
                                    .foregroundColor(.black)
                                    .font(.system(size: 15, weight: .semibold))
                                let email = UserSessionManager.getUserData().email 
                                Text(email)
                                    .foregroundColor(.black)
                                    .font(.system(size: 12, weight: .semibold))
                                
                            }
                            Spacer()
                        }
                        .frame(height: 120)
                        .background(.gray.opacity(0.3))
                        .cornerRadius(20)
                        
                        
                        VStack(alignment: .leading,spacing:5) {
                            Text(StringConstants.account)
                                .font(.system(size: 25, weight: .semibold))
                            
                            CommonCell(title: StringConstants.accountInformation,action: {
                                router.navigateToAuth(.accountInformation)
                            })
                            CommonCell(title: StringConstants.resetPassword,action: {
                                alertType  = .resetPassword
                                alert = true
                                alertTitle = StringConstants.resetPassword
                                alertMessage = "\(StringConstants.resetPasswordDes) \(UserSessionManager.getUserData().email )."
                                alertButtonText = StringConstants.sendEmail
                            })
                        }
                        .padding(.top,5)
                        
                        VStack(alignment: .leading,spacing:5) {
                            Text(StringConstants.privacy)
                                .font(.system(size: 25, weight: .semibold))
                            
                            CommonCell(title: StringConstants.privacyPolicy,action: {
                                if let url = URL(string: "https://www.offhandlabs.com/privacy-policy") {
                                    UIApplication.shared.open(url)
                                }
                            })
                            
                            CommonCell(title: StringConstants.termsAndConditions,action: {
                                //
                            })
                            
                            CommonCell(title: StringConstants.helpAndSupport,action: {
                                //
                            })
                        }
                        .padding(.top)
                        
                        VStack(alignment: .leading,spacing:5) {
                            Text(StringConstants.securityOptions)
                                .font(.system(size: 25, weight: .semibold))
                            CommonCell(title: StringConstants.logout,action: {
                                alertType  = .logout
                                alert = true
                                alertTitle = StringConstants.confirmLogout
                                alertMessage = StringConstants.logoutDes
                                alertButtonText = StringConstants.logout
                            })
                            
                            CommonCell(title: StringConstants.delete,textColor:.red,action: {
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
                                router.navigateToAuthRoot()
                                UserSessionManager.clearUserData()
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
    
    private func CommonCell(title: String,textColor:Color = .black, placeholder: String = "Type here", action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundStyle(textColor)
                    .padding()
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .frame(width: 15, height: 20)
                    .padding()
            }
            .frame(height: 50)
            .background(Color.white)
            .cornerRadius(8)
            .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 4)
            .accentColor(.black)
            .foregroundColor(.black)
            .font(.system(size: 20))
            .padding(.bottom)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    func deleteAccount() {
        GoogleSignInManager.shared.deleteAccount { result in
            switch result {
            case .success():
                router.navigateToAuthRoot()
                UserSessionManager.clearUserData()
            case .failure(let error):
                errorAlert = true
                alertMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    SettingView()
}

