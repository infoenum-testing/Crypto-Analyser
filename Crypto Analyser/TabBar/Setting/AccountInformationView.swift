//
//  AccountInformationView.swift
//  Crypto Analyser
//
//  Created by IE15 on 23/12/24.
//

import SwiftUI

struct AccountInformationView: View {
    @EnvironmentObject var router: Router
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
                    Text("Profile")
                        .font(.system(size: 25, weight: .semibold))
                    
                    Spacer()
                    Text("")
                }
                .padding(.horizontal,20)
               
                
                ScrollView(showsIndicators:false) {
                    VStack {
                        VStack(spacing:5) {
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .foregroundColor(.black)
                                .frame(width: 50,height: 50)
                                .padding(.leading)
                            VStack {
                                let name = UserSessionManager.getUserData().name 
                                Text(name)
                                    .foregroundColor(.black)
                                    .font(.system(size: 20, weight: .semibold))
                                let email = UserSessionManager.getUserData().email 
                                Text(email)
                                    .foregroundColor(.black)
                                    .font(.system(size: 12, weight: .semibold))
                                
                            }
                            Spacer()
                        }
//                        .frame(height: 120)
//                        .background(.gray.opacity(0.3))
//                        .cornerRadius(20)
                        
                        
                        VStack(alignment: .leading,spacing:5) {
                            CommonCell(title: "Edit Profile",action: {
                                router.navigateToAuth(.editProfile)
                            })
                           
                        }
                        .padding(.top,5)
                        
                
                        VStack(alignment: .leading,spacing:5) {
                            Text("Subscriptions")
                                .font(.system(size: 25, weight: .semibold))
                            CommonCell(title: "Monthly",action: {
                                //
                            })
                            
                            CommonCell(title: "Yearly",action: {
                                //
                            })
                        }
                        .padding(.top)
                        
                    }
                    .padding(.horizontal,20)
                }
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
        .buttonStyle(PlainButtonStyle()) // Removes default button appearance
    }
}

#Preview {
    AccountInformationView()
}
