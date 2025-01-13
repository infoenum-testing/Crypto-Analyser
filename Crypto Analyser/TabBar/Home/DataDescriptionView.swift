//
//  DataDescriptionView.swift
//  Crypto Analyser
//
//  Created by IE15 on 02/01/25.
//

import SwiftUI

struct DataDescriptionView: View {
    @EnvironmentObject var router: Router
    let image: UIImage
    let afterAnalyse:Bool
    let title: String?
    let message: String
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    router.navigateBackInAuth()
                }, label: {
                    Image(.back)
                        .foregroundColor(.black)
                })
                Spacer()
                Text("Analysed Result")
                    .font(.system(size: 25, weight: .semibold))
                Spacer()
                Text(" ")
            }
            .padding(.horizontal, 20)
            .frame(height: 30)
            .clipped()
            
            ZStack {
                ScrollView {
                    VStack {
                        VStack {
                            ZStack {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: UIScreen.main.bounds.width - 16)
                                    .frame(maxHeight: UIScreen.main.bounds.height/2.3)
                                    .clipped()
                            }
                            .frame(maxHeight: UIScreen.main.bounds.height/2.5)
                            .cornerRadius(8)
                            .shadow(color: Color.black, radius: 3, x: 0, y: 0)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        }
                        Text(message)
                            .font(.system(size: 20, weight: .regular))
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .transition(.opacity)
                        
                    }
                }
            }
        }
    }
}

#Preview {
    DataDescriptionView(image: UIImage(), afterAnalyse: false, title: nil, message: "")
}
