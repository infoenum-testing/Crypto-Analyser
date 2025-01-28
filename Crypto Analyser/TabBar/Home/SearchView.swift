//
//  SearchView.swift
//  Crypto Analyser
//
//  Created by IE15 on 26/12/24.
//

import SwiftUI
import WebKit

struct SearchView: View {
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
                            .foregroundColor(.black)
                    })
                    Spacer()
                    Text("Search Coin")
                        .font(.system(size: 25, weight: .semibold))
                    Spacer()
                    Button(action: {
                        capture.toggle()
                    }, label: {
                        Image(systemName: "camera.on.rectangle.fill")
                            .foregroundColor(.black)
                    })
                }
                .padding(.horizontal, 20)
            }
            SearchWebView(screenshot: $screenshot, capture: $capture, symbol: symbol)
        }
        .onChange(of: screenshot, perform: { value in
            if let value {
                router.navigateToAuth(.imageAnalyser(image: value.resized(to: 800), fromSearch: true))
            }
        })
    }
}



