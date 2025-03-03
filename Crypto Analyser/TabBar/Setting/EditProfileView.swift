//
//  EditProfileView.swift
//  Crypto Analyser
//
//  Created by IE15 on 23/12/24.
//

import SwiftUI

struct EditProfileView: View {
    enum FocusedField: Hashable {
        case emailField, password , name
    }
    
    @EnvironmentObject var router: Router
    @FocusState private var activeField: FocusedField?
    
    @State private var isSaveButtonDisabled: Bool = true
    @State private var isPasswordVisible: Bool = false
    @State private var showAlert: Bool = false
    @State private var isLoading: Bool = false
    
    @State private var errorMessage: String = ""
    @State private var email: String = (UserSessionManager.getUserData().email )
    @State private var name: String = (UserSessionManager.getUserData().name )
    
    @StateObject private var borderAnimationViewModel = BorderAnimationViewModel()
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
                    Text(StringConstants.editProfile)
                        .foregroundStyle(Color.white)
                        .font(.system(size: 25, weight: .semibold))
                    
                    Spacer()
                    Text("")
                }
                .padding(.horizontal,20)
                VStack {
                    formField(title: StringConstants.nameTitle, text: $name, focusedField: .name, placeholder: StringConstants.nameTitle)
                        .padding(.horizontal, 20)
                    
                    formField(title: StringConstants.emailTitle, text: $email, focusedField: .emailField, placeholder: StringConstants.emailTitle)
                        .padding(.horizontal, 20)
                        .disabled(true)
                }
                .padding(5)
                .padding(.top)
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
                saveButton
                    .padding(.horizontal, 20)
                    .padding(.bottom,30)
                
                
            }
            if isLoading {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ProgressView()
                            .controlSize(.large)
                            .tint(.pink)
                     
                        Spacer()
                    }
                    Spacer()
                }
                .background(.black.opacity(0.4))
            }
        }
        .background(Color.themecolor)
        .alert(isPresented: $showAlert) {
            Alert(title: Text(StringConstants.validationErrorTitle), message: Text(errorMessage), dismissButton: .default(Text(StringConstants.oKText)){
                router.navigateBackInAuth()
            })
        }
    }
    private func formField(title: String, text: Binding<String>, focusedField: FocusedField, placeholder: String = "Type here") -> some View {
        VStack(alignment: .leading) {
            let isEmail = focusedField == .emailField ? true : false
            Text(title)
                .font(.system(size: 20))
                .foregroundColor(.white)
            TextField(placeholder, text: text)
                .foregroundColor(isEmail ? .gray : .white)
                .keyboardType(.alphabet)
                .textInputAutocapitalization(.words)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding()
                .frame(height: 50)
                .background(Color.cellcolor)
                .cornerRadius(8)
                .accentColor(.blue)
                .foregroundColor(.black)
                .font(.system(size: 20))
                .focused($activeField, equals: focusedField)
        }
        .padding(.bottom)
    }
    
    
    
    private var saveButton: some View {
        Button(action: {
            if !name.isEmpty{
                activeField = nil
                isLoading = true
                FirebaseAuthentication.shared.updateUserName(email: email, newName: name) { result in
                    isLoading = false
                    switch result {
                    case .success:
                        router.navigateBackInAuth()
                        UserSessionManager.saveUserData(name: name, email: email, loginBy: nil)
                    case .failure(let error):
                        errorMessage = "Login failed: \(error.localizedDescription)"
                        showAlert = true
                    }
                }
            } else {
                errorMessage = StringConstants.validationNameEmpty
                showAlert = true
            }
        }, label: {
            HStack {
                Text(StringConstants.save)
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
}

#Preview {
    EditProfileView()
}
