//
//  SignUpView.swift
//  Crypto Analyser
//
//  Created by IE15 on 20/12/24.
//

import SwiftUI

struct SignUpView: View {
    enum FocusedField: Hashable {
        case nameField, emailField, password, conformPassword
    }
    @StateObject private var borderAnimationViewModel = BorderAnimationViewModel()
    @EnvironmentObject var router: Router
    @FocusState private var activeField: FocusedField?
    
    @State private var isSaveButtonDisabled: Bool = true
    @State private var isPasswordVisible: Bool = false
    @State private var isConformPasswordVisible: Bool = false
    @State private var showAlert: Bool = false
    @State private var isLoading: Bool = false
    
    @State private var errorMessage: String = ""
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var conformPassword: String = ""
    
    var body: some View {
        ZStack {
            VStack {
                ScrollView(showsIndicators: false) {
                    HStack {
                        Text(StringConstants.signUpTitle)
                            .foregroundStyle(Color.white)
                            .font(.system(size: 30, weight: .semibold))
                            .padding(.top, 10)
                        Spacer()
                    }
                    
                    .padding(.horizontal, 20)
                    VStack {
                        formField(title: StringConstants.nameTitle, text: $name, focusedField: .nameField, placeholder: StringConstants.nameTitle)
                            .padding(.top, 10)
                            .padding(.horizontal, 10)
                        
                        formField(title: StringConstants.emailTitle, text: $email, focusedField: .emailField, placeholder: StringConstants.emailTitle)
                            .padding(.horizontal, 10)
                        
                        passwordField(title: StringConstants.passwordTitle, text: $password, focusedField: .password, placeholder: StringConstants.passwordTitle, isPasswordVisible: $isPasswordVisible)
                            .padding(.horizontal, 10)
                        
                        passwordField(title: StringConstants.confirmPasswordTitle, text: $conformPassword, focusedField: .conformPassword, placeholder: StringConstants.confirmPasswordTitle, isPasswordVisible: $isConformPasswordVisible)
                            .padding(.horizontal, 10)
                    }
                    .padding(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 40)
                            .stroke(LinearGradient(
                                gradient: Gradient(colors: borderAnimationViewModel.gradientColors),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ), lineWidth: 4) // Gradient border
                            .blur(radius: 5) // Glow effect
                    )
                    .padding()
                    
                    Spacer()
                    
                    signUpButton
                        .padding(.horizontal, 20)
                        .padding(.top,30)
                    HStack(spacing: 5) {
                        Text(StringConstants.alreadyHaveAnAccount)
                            .foregroundStyle(Color.white)
                            .font(.system(size: 15))
                        Button(action: {
                            router.navigateBackInAuth()
                        }, label: {
                            Text(StringConstants.loginTitle)
                                .foregroundStyle(.pink)
                                .font(.system(size: 18, weight: .semibold))
                        })
                    }
                    .padding(.top,3)
                    
                }
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
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button(action: {
                        activeField = nil
                    }, label: {
                        Text(StringConstants.done)
                            .foregroundStyle(.blue)
                            .font(.system(size: 18, weight: .regular))
                    })
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(StringConstants.validationErrorTitle), message: Text(errorMessage), dismissButton: .default(Text(StringConstants.oKText)))
        }
        .toolbarBackground(Color.white, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
        .background(Color.themecolorprimary)
    }
    
    private func formField(title: String, text: Binding<String>, focusedField: FocusedField, placeholder: String = "Type here") -> some View {
        let autocapitalization: TextInputAutocapitalization = focusedField == .emailField ? .never : .words
        let keyboardType: UIKeyboardType = focusedField == .emailField ? .emailAddress : .alphabet
        return VStack(alignment: .leading) {
            Text(title)
                .font(.system(size: 20))
                .foregroundColor(.white)
            TextField("", text: text)
                .placeholder(when: text.wrappedValue.isEmpty) {
                    Text(placeholder)
                        .foregroundColor(.gray)
                }
                .keyboardType(keyboardType)
                .textInputAutocapitalization(autocapitalization)
                .disableAutocorrection(true)
                .padding()
                .frame(height: 50)
                .background(Color.cellcolortheme)
                .cornerRadius(8)
                .accentColor(.white)
                .foregroundColor(.white)
                .font(.system(size: 20))
                .focused($activeField, equals: focusedField)
                .onSubmit {
                    if focusedField == .nameField {
                        activeField = .emailField
                    } else if focusedField == .emailField {
                        activeField = .password
                    }
                }
        }
        .padding(.bottom)
    }
    
    private func passwordField(title: String, text: Binding<String>, focusedField: FocusedField, placeholder: String, isPasswordVisible: Binding<Bool>) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.system(size: 20))
                .foregroundColor(.white)
            HStack {
                if isPasswordVisible.wrappedValue {
                    TextField("", text: text)
                        .placeholder(when: text.wrappedValue.isEmpty) {
                            Text(placeholder)
                                .foregroundColor(.gray)
                        }
                        .accentColor(.white)
                        .focused($activeField, equals: focusedField)
                        .onSubmit {
                            if focusedField == .password {
                                activeField = .conformPassword
                            }
                        }
                } else {
                    SecureField("", text: text)
                        .placeholder(when: text.wrappedValue.isEmpty) {
                            Text(placeholder)
                                .foregroundColor(.gray)
                        }
                        .accentColor(.white)
                        .focused($activeField, equals: focusedField)
                        .onSubmit {
                            if focusedField == .password {
                                activeField = .conformPassword
                            }
                        }
                }
                Button(action: {
                    withAnimation {
                        isPasswordVisible.wrappedValue.toggle()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        activeField = focusedField
                    }
                }) {
                    Image(systemName: !isPasswordVisible.wrappedValue ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .frame(height: 50)
            .background(Color.cellcolortheme)
            .cornerRadius(8)
        }
        .padding(.bottom)
    }
    
    
    private var signUpButton: some View {
        Button(action: {
            activeField = nil
            if validateFields() {
                isLoading = true
                FirebaseAuthentication.shared.registerUser(email: email, password: password, name: name) { result in
                    isLoading = false
                    switch result {
                    case .success:
                        router.navigateToAuth(.tabBar)
                    case .failure(let error):
                        errorMessage = "Registration failed: \(error.localizedDescription)"
                        showAlert = true
                    }
                }
            }
        }, label: {
            HStack {
                Text(StringConstants.signUpTitle)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 20)
            .padding()
            .background(Color.buttonbackgroundtheme)
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
    
    private func validateFields() -> Bool {
        if name.isEmpty {
            errorMessage = StringConstants.validationNameEmpty
            showAlert = true
            return false
        }
        if email.isEmpty || !isValidEmail(email) {
            errorMessage = email.isEmpty ? StringConstants.validationEmailEmpty : StringConstants.validationEmailInvalid
            showAlert = true
            return false
        }
        if password.isEmpty {
            errorMessage = StringConstants.validationPasswordEmpty
            showAlert = true
            return false
        }
        if conformPassword.isEmpty {
            errorMessage = StringConstants.validationConfirmPasswordEmpty
            showAlert = true
            return false
        }
        if password != conformPassword {
            errorMessage = StringConstants.validationPasswordsMismatch
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
    SignUpView()
}
