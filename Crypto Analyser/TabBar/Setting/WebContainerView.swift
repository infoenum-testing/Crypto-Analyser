//
//  WebContainerView.swift
//  Crypto Analyser
//
//  Created by IE MacBook Pro 2014 on 02/01/25.
//

import Foundation
import Foundation
import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let wkwebView = WKWebView()
        let request = URLRequest(url: url)
        wkwebView.load(request)
        return wkwebView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
}
struct WebViewContainer: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State var isLoading: Bool = true
    @State var isHeaderViewHidden : Bool = false
    let url: URL
    var title : String
    
    var body: some View {
    
        VStack {
            /// Header view
            if !isHeaderViewHidden {
            ZStack {
                HStack {
                    Spacer()
                    Text(title)
                        .fontWeight(.bold)
                        .font(.title2)
                        .foregroundColor(.black)
                    Spacer()
                }
                HStack {
                    Spacer()
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        HStack {
                           // Image("multiply")
                            Image(systemName: "multiply")
                                .resizable()
                                .foregroundColor(.black)
                                .frame(width: 20, height: 20)
                        }.padding(.trailing)
                            
                    }
                }
            }
        }
        
            ZStack {
              
                WebView(url: url)
                
                if isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.white.opacity(0.8))
                    Spacer()
                }
            }
            .navigationBarTitle(title, displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image("multiply")
                    }
                }
            }
            .onAppear{
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    isLoading = false
                }
            }
        }
    }
}
