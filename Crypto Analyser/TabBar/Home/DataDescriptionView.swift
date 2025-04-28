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
    let confidenceLevel: String
    let message: String
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    router.navigateBackInAuth()
                }, label: {
                    Image(.back)
                        .foregroundColor(.white)
                })
                Spacer()
                Text(StringConstants.analysedResult)
                    .foregroundColor(.white)
                    .font(.system(size: 25, weight: .semibold))
                Spacer()
                Text(" ")
            }
            .padding(.horizontal, 20)
            .frame(height: 30)
            .clipped()
            
            ZStack {
                ScrollView(showsIndicators: false)  {
                    VStack {
                        VStack {
                            ZStack {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: UIScreen.main.bounds.width - 40)
                                    .frame(maxHeight: UIScreen.main.bounds.height/2.3)
                                    .clipped()
                            }
                            .frame(maxHeight: UIScreen.main.bounds.height/2.5)
                            .cornerRadius(8)
                            .shadow(color: Color.black, radius: 3, x: 0, y: 0)
                            .padding(.top, 20)
                        }
                        Text(message)
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .regular))
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .transition(.opacity)
                      
                        ConfidenceMeter(value: Double(confidenceLevel) ?? 50)
                               .padding(.leading,UIScreen.main.bounds.width * 0.1)
                    }
                }
            }
        }
        .background(Color.themecolorprimary)
    }
}

#Preview {
    DataDescriptionView(image: UIImage(), afterAnalyse: false, confidenceLevel: "50", message: "")
}
