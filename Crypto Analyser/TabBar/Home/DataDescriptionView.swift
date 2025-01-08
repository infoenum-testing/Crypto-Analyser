//
//  DataDescriptionView.swift
//  Crypto Analyser
//
//  Created by IE15 on 02/01/25.
//

import SwiftUI

struct DataDescriptionView: View {
    @EnvironmentObject var router: Router
    let afterAnalyse:Bool
    let title: String?
    let message: String
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    if afterAnalyse {
                        router.navigateBackInAuth()
                        router.navigateBackInAuth()
                    } else {
                        router.navigateBackInAuth()
                    }
                }, label: {
                    Image(.back)
                        .foregroundColor(.black)
                })
                Spacer()
                Text("Analysed")
                    .font(.system(size: 25, weight: .semibold))
                Spacer()
                Text("")
            }
            .padding(.horizontal, 20)
            .frame(height: 50)
            .clipped()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .center) {
                    VStack(alignment: .leading) {
                        if let title {
                            Text(title)
                                .font(.system(size: 20, weight: .semibold))
                                .padding(.bottom,5)
                        }
                        Text(message)
                            .font(.system(size: 20, weight: .regular))
                    }
                    .padding(.horizontal)
                }
                
            }
        }
    }
}

#Preview {
    DataDescriptionView(afterAnalyse: false, title: nil, message: "")
}
