//
//  SearchView.swift
//  Crypto Analyser
//
//  Created by IE15 on 26/12/24.
//

import SwiftUI
import WebKit

struct SearchView: View {
    @StateObject private var borderAnimationViewModel = BorderAnimationViewModel()
    @EnvironmentObject var router: Router
    let symbol:String
    @State private var showCancelButton: Bool = false
    @State private var screenshot: UIImage?
    @State private var capture: Bool = false
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Button(action: {
                        router.navigateBackInAuth()
                    }, label: {
                        Image(.back)
                            .foregroundColor(.white)
                    })
                    Spacer()
                    Text(StringConstants.searchCoin)
                        .foregroundColor(.white)
                        .font(.system(size: 25, weight: .semibold))
                    Spacer()
                    Text(" ")
                }
                .padding(.horizontal, 20)
            }
            SearchWebView(screenshot: $screenshot, capture: $capture, symbol: symbol)
            analyseButton
                .padding(.horizontal, 20)
        }
        .background(Color.themecolor)
        .ignoresSafeArea(.keyboard)
        .onChange(of: screenshot, perform: { value in
            if let value {
                router.navigateToAuth(.imageAnalyser(image: value.resized(to: 800), fromSearch: true))
            }
        })
        .onAppear {borderAnimationViewModel.startColorAnimation()}
        .onDisappear {borderAnimationViewModel.stopColorAnimation()}
    }
    private var analyseButton: some View {
        Button(action: {
            capture.toggle()
        }, label: {
            HStack {
                Text(StringConstants.analyse)
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
    }
}



