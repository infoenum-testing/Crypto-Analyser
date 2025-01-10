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
                    Text("Edit Profile")
                        .font(.system(size: 25, weight: .semibold))
                    
                    Spacer()
                    Text("")
                }
                .padding(.horizontal,20)
              
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .foregroundColor(.black)
                        .frame(width: 50,height: 50)
                        .padding(.leading)
                    
                    formField(title: StringConstants.nameTitle, text: $name, focusedField: .name, placeholder: StringConstants.nameTitle)
                        .padding(.horizontal, 20)
                    
                    formField(title: StringConstants.emailTitle, text: $email, focusedField: .emailField, placeholder: StringConstants.emailTitle)
                        .padding(.horizontal, 20)
                        .disabled(true)
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
                            .foregroundColor(.white)
                        //     .scaleEffect(3)
                        Spacer()
                    }
                    Spacer()
                }
                .background(.black.opacity(0.4))
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(StringConstants.validationErrorTitle), message: Text(errorMessage), dismissButton: .default(Text(StringConstants.oKText)))
        }
    }
    private func formField(title: String, text: Binding<String>, focusedField: FocusedField, placeholder: String = "Type here") -> some View {
        VStack(alignment: .leading) {
            let isEmail = focusedField == .emailField ? true : false
            Text(title)
                .font(.system(size: 20))
                .foregroundColor(.black)
            TextField(placeholder, text: text)
                .foregroundColor(isEmail ? .gray : .black)
                .keyboardType(.alphabet)
                .textInputAutocapitalization(.words)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding()
                .frame(height: 50)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 4)
                .accentColor(.black)
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
                        router.navigateBackInAuth()
                        UserSessionManager.saveUserData(name: name, email: email)
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
                Text("Save")
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
    
    
}

#Preview {
    EditProfileView()
}
