//
//  LoginView.swift
//  Crypto Analyser
//
//  Created by IE15 on 20/12/24.
//

import SwiftUI

struct LoginView: View {
    enum FocusedField: Hashable {
        case emailField, password
    }
    @StateObject private var borderAnimationViewModel = BorderAnimationViewModel()
    @EnvironmentObject var router: Router
    @FocusState private var activeField: FocusedField?
    
    @State private var isSaveButtonDisabled: Bool = true
    @State private var isPasswordVisible: Bool = false
    @State private var showAlert: Bool = false
    @State private var isLoading: Bool = false
    
    @State private var errorMessage: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        ZStack {
            VStack {
                ScrollView(showsIndicators: false) {
                    HStack {
                        Text(StringConstants.loginTitle)
                            .foregroundStyle(.white)
                            .font(.system(size: 30, weight: .semibold))
                            .padding(.top, 10)
                            .padding(.bottom, 25)
                        Spacer()
                         }
                    .padding(.horizontal, 20)
                    VStack {
                        formField(title: StringConstants.emailTitle, text: $email, focusedField: .emailField, placeholder: StringConstants.emailTitle)
                            .padding(.horizontal, 10)
                        
                        passwordField(title: StringConstants.passwordTitle, text: $password, focusedField: .password, placeholder: StringConstants.passwordTitle, isPasswordVisible: $isPasswordVisible)
                            .padding(.horizontal, 10)
                        HStack {
                            Spacer()
                            Button(action: {
                                router.navigateToAuth(.forgotPassword)
                            }, label: {
                                Text(StringConstants.forgotPassword)
                                    .foregroundStyle(Color.pink)
                                    .font(.system(size: 18, weight: .semibold))
                            })
                        }
                        .padding(.horizontal, 10)
                    }
                    .padding(.vertical,20)
                    .padding(.horizontal)
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
                    loginButton
                        .padding(.horizontal, 20)
                        .padding(.top,UIScreen.main.bounds.height/5)
                    HStack(spacing: 5) {
                        Text(StringConstants.doNotHaveAccount)
                            .foregroundStyle(.white)
                            .font(.system(size: 15))
                        Button(action: {
                            router.navigateToAuth(.signUp)
                        }, label: {
                            Text(StringConstants.signUpTitle)
                                .foregroundStyle(Color.pink)
                                .font(.system(size: 18, weight: .semibold))
                        })
                    }
                    .padding(.top,3)
                    
                    Text(StringConstants.orText)
                        .foregroundColor(.white)
                        .font(.system(size: 15, weight: .semibold))
                        .padding()
                    
                    HStack(spacing: 55) {
                        Button(action: {
                            isLoading = true
                            GoogleSignInManager.shared.signInWithGoogle { result in
                                isLoading = false
                                switch result {
                                case .success((let name,let email)):
                                    UserSessionManager.saveUserData(name: name, email: email, loginBy: .google)
                                    router.navigateToAuth(.tabBar)
                                case .failure(let error):
                                    if error.localizedDescription !=  "Cancel" {
                                        errorMessage = "Login failed: \(error.localizedDescription)"
                                        showAlert = true
                                    }
                                }
                            }
                        }, label: {
                            Image(.googleIcon)
                                .resizable()
                                .frame(width: 35,height: 35)
                        })
                        
                        Button(action: {
                            isLoading = true
                            FirebaseAppleLoginViewModel.shared.login { result in
                                isLoading = false
                                switch result {
                                case .success(let auth):
                                    router.navigateToAuth(.tabBar)
                                case .failure(let error):
                                    if error.localizedDescription !=  "Cancel" {
                                        errorMessage = "Login failed: \(error.localizedDescription)"
                                        showAlert = true
                                    }
                                }
                            }
                            
                        }, label: {
                            Image(.appleIcon)
                                .resizable()
                                .foregroundColor(.white)
                                .frame(width: 40,height: 40)
                        })
                    }
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
                        //  .scaleEffect(3)
                        Spacer()
                    }
                    Spacer()
                }
                .background(.black.opacity(0.2))
            }
        }
        .background(Color.themecolor)
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button(action: {
                       activeField = nil
                    }, label: {
                        Text("Done")
                            .foregroundStyle(.blue)
                            .font(.system(size: 18, weight: .regular))
                    })
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(StringConstants.validationErrorTitle), message: Text(errorMessage), dismissButton: .default(Text(StringConstants.oKText)))
        }
    }
    
    private func formField(title: String, text: Binding<String>, focusedField: FocusedField, placeholder: String = "Type here") -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.system(size: 20))
                .foregroundColor(.white)
            TextField("", text: text)
                .placeholder(when: text.wrappedValue.isEmpty) {
                    Text(placeholder)
                        .foregroundColor(.gray)
                }
                .foregroundColor(.white)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding()
                .frame(height: 50)
                .background(Color.cellcolor)
                .cornerRadius(8)
                .accentColor(.white)
                .foregroundColor(.black)
                .font(.system(size: 20))
                .focused($activeField, equals: focusedField)
                .onSubmit {
                    activeField = .password
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
                        .foregroundColor(.white)
                        .accentColor(.white)
                        .focused($activeField, equals: focusedField)
                        .disableAutocorrection(true)
                } else {
                    SecureField("", text: text)
                        .placeholder(when: text.wrappedValue.isEmpty) {
                            Text(placeholder)
                                .foregroundColor(.gray)
                        }
                        .foregroundColor(.white)
                        .accentColor(.white)
                        .focused($activeField, equals: focusedField)
                        .disableAutocorrection(true)
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
            .background(Color.cellcolor)
            .cornerRadius(8)
        }
        .padding(.bottom)
        .onAppear{
            print(UIScreen.main.bounds.height)
        }
    }
    
    
    private var loginButton: some View {
        Button(action: {
            activeField = nil
            if validateFields() {
                isLoading = true
                FirebaseAuthentication.shared.loginUser(email: email, password: password) { result in
                    isLoading = false
                    switch result {
                    case .success:
                        print("success")
                        router.navigateToAuth(.tabBar)
                    case .failure(let error):
                        errorMessage = "Login failed: \(error.localizedDescription)"
                        showAlert = true
                    }
                }
            }
        }, label: {
            HStack {
                Text(StringConstants.loginTitle)
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
    
    private func validateFields() -> Bool {
        if email.isEmpty || !isValidEmail(email) {
            errorMessage = email.isEmpty ? StringConstants.validationEmailEmpty : StringConstants.invalidEmailError
            showAlert = true
            return false
        }
        
        if password.isEmpty {
            errorMessage = StringConstants.passwordEmptyError
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
    LoginView()
}

