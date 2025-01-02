//
//  AnalyseView.swift
//  Crypto Analyser
//
//  Created by IE15 on 26/12/24.
//

import SwiftUI

struct ImageAnalyserView: View {
    @EnvironmentObject var router: Router
    @State public var image: UIImage
    @State private var isLoading: Bool = true
    
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
            }
            .padding(.horizontal, 20)
            .frame(height: 50)
            .clipped()
            
            VStack {
                Spacer()
                
                ZStack {
                    VStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: UIScreen.main.bounds.width, height: 300)
                            .clipped()
                            .contentShape(Rectangle())  // Make sure the image is tappable if needed
                    }
                    .frame(height: 300)
                    
                    if isLoading {
                        LeafLoadingView()
                    }
                }
                
                if !isLoading {
                    VStack(alignment: .center, spacing: 5) {
                        Spacer()
                        Text("No chat was found in the image - You can")
                            .font(.system(size: 15, weight: .regular))
                        Text("Search for a coin")
                            .foregroundStyle(Color.blue)
                            .font(.system(size: 15, weight: .semibold))
                            .onTapGesture {
                                router.navigateBackInAuth()
                                router.navigateToAuth(.searchView)
                            }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                } else {
                    Spacer()
                }
            }
        }
        .padding(.top, 5)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                withAnimation(.easeInOut) {
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    ImageAnalyserView(image: UIImage())
}
