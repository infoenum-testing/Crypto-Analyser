//
//  ForgotPassword.swift
//  Crypto Analyser
//
//  Created by IE15 on 20/12/24.
//

import SwiftUI

struct ForgotPassword: View {
    @EnvironmentObject var router: Router
    
    @State private var isSaveButtonDisabled: Bool = true
    @State private var showAlert: Bool = false
    @State private var isLoading: Bool = false
    
    @State private var errorTitle: String = StringConstants.validationErrorTitle
    @State private var errorMessage: String = ""
    @State private var email: String = ""
    
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button(action: {
                        router.navigateBackInAuth()
                    }, label: {
                        Image(.back)
                            .foregroundColor(.black)
                    })
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                
                Text(StringConstants.forgotPasswordTitle)
                    .font(.system(size: 30, weight: .semibold))
                    .padding(.top, 10)
                HStack {
                    Text(StringConstants.passwordResetDes)
                        .font(.system(size: 18))
                        .padding(.bottom, 30)
                        .padding(.horizontal, 20)
                    Spacer()
                }
                .padding(.top, 10)
                
                formField(title: StringConstants.emailTitle, text: $email, placeholder: StringConstants.emailTitle)
                    .padding(.horizontal, 20)
                Spacer()
                sendButton
                    .padding(.horizontal, 20)
                    .padding(.bottom, 50)
                
            }
            if isLoading {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ProgressView()
                            .controlSize(.large)
                            .foregroundColor(.white)
                        //                           .scaleEffect(3)
                        Spacer()
                    }
                    Spacer()
                }
                .background(.black.opacity(0.2))
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(errorTitle),
                message: Text(errorMessage),
                dismissButton: .default(Text(StringConstants.oKText)) {
                    if  errorTitle != StringConstants.emailTitle {
                        router.navigateBackInAuth()
                    }
                }
            )
        }
    }
    
    private func formField(title: String, text: Binding<String>, placeholder: String = "Type here") -> some View {
        return VStack(alignment: .leading) {
            Text(title)
                .font(.system(size: 20))
                .foregroundColor(.black)
            TextField(placeholder, text: text)
                .keyboardType(.emailAddress)
                .disableAutocorrection(true)
                .padding()
                .frame(height: 50)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 4)
                .accentColor(.black)
                .foregroundColor(.black)
                .font(.system(size: 20))
        }
        .padding(.bottom)
    }
    
    private var sendButton: some View {
        Button(action: {
            if validateFields() {
                isLoading = true
                FirebaseAuthentication.shared.forgotPassword(email: email) { result in
                    isLoading = false
                    switch result {
                    case .success(_):
                        errorTitle = StringConstants.checkYourEmail
                        errorMessage = "A password reset link has been sent to \(email). Please check your inbox and follow the instructions to reset your password."
                        showAlert = true
                    case .failure(let error):
                        errorTitle = StringConstants.emailTitle
                        errorMessage = error.localizedDescription
                        showAlert = true
                    }
                }
            }
        }, label: {
            HStack {
                Text(StringConstants.send)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 20)
            .padding()
            .background(Color.midnightBlue)
            .cornerRadius(10)
        })
        .disabled(isLoading)
    }
    
    private func validateFields()-> Bool {
        errorTitle = StringConstants.validationErrorTitle
        if email.isEmpty || !isValidEmail(email) {
            errorMessage = email.isEmpty ? StringConstants.validationEmailEmpty : StringConstants.invalidEmailError
            showAlert = true
            return false
        }
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

#Preview {
    ForgotPassword()
}
