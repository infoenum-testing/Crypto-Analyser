//
//  ForgotPassword.swift
//  Crypto Analyser
//
//  Created by IE15 on 20/12/24.
//

import SwiftUI

struct ForgotPassword: View {
    @StateObject private var borderAnimationViewModel = BorderAnimationViewModel()
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
                            .foregroundColor(.white)
                    })
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                HStack {
                Text(StringConstants.forgotPasswordTitle)
                    .foregroundColor(.white)
                    .font(.system(size: 30, weight: .semibold))
                    .padding(.top, 10)
                    Spacer()
                }
                .padding(.horizontal, 20)
                
                HStack {
                    Text(StringConstants.passwordResetDes)
                        .foregroundColor(.white)
                        .font(.system(size: 18))
                        .padding(.bottom, 30)
                        .padding(.horizontal, 20)
                    Spacer()
                }
                .padding(.top, 10)
                VStack {
                    formField(title: StringConstants.emailTitle, text: $email, placeholder: StringConstants.emailTitle)
                        .padding(.horizontal, 10)
                }
                .padding(.vertical,20)
                .padding(.horizontal)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(LinearGradient(
                            gradient: Gradient(colors: borderAnimationViewModel.gradientColors),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ), lineWidth: 4) // Gradient border
                        .blur(radius: 5) // Glow effect
                )
                .padding()
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
                            .tint(Color.pink)
                        Spacer()
                    }
                    Spacer()
                }
                .background(.black.opacity(0.2))
            }
        }
        .background(Color.themecolor)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(errorTitle),
                message: Text(errorMessage),
                dismissButton: .default(Text(StringConstants.oKText)) {
                    if  errorTitle != StringConstants.emailTitle &&  errorTitle != StringConstants.error {
                        router.navigateBackInAuth()
                    }
                }
            )
        }
        .toolbar {
              ToolbarItem(placement: .keyboard) {
                HStack {
                  Spacer()
                    Button(action: {
                        KeyboardUtility.hideKeyboard()
                    }, label: {
                        Text(StringConstants.done)
                            .foregroundStyle(.blue)
                            .font(.system(size: 18, weight: .regular))
                            
                    })
                }
              }
            }
    }
    
    private func formField(title: String, text: Binding<String>, placeholder: String = "Type here") -> some View {
        return VStack(alignment: .leading) {
            Text(title)
                .font(.system(size: 20))
                .foregroundColor(.white)
            TextField("", text: text)
                .placeholder(when: text.wrappedValue.isEmpty) {
                    Text(placeholder)
                        .foregroundColor(.gray)
                }
                .keyboardType(.emailAddress)
                .disableAutocorrection(true)
                .padding()
                .frame(height: 50)
                .background(Color.cellcolor)
                .cornerRadius(8)
                .accentColor(.white)
                .foregroundColor(.white)
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
            .background(Color.buttonbackground)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(LinearGradient(
                        gradient: Gradient(colors: borderAnimationViewModel.gradientColors),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ), lineWidth: 4)
                    .blur(radius: 2)
            )
        })
        .disabled(isLoading)
        .onAppear {borderAnimationViewModel.startColorAnimation()}
        .onDisappear {borderAnimationViewModel.stopColorAnimation()}
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
