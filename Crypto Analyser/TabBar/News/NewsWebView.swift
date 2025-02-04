//
//  NewsWebView.swift
//  Crypto Analyser
//
//  Created by IE15 on 10/01/25.
//

import Foundation
import WebKit
import SwiftUI

//struct NewsWebView: UIViewRepresentable {
//    let url: URL
//    @Binding var canGoBack: Bool
//    @Binding var canGoForward: Bool
//    
//    class Coordinator: NSObject, WKNavigationDelegate {
//        var parent: NewsWebView
//        
//        init(parent: NewsWebView) {
//            self.parent = parent
//        }
//        
//        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//            parent.canGoBack = webView.canGoBack
//            parent.canGoForward = webView.canGoForward
//        }
//    }
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(parent: self)
//    }
//    
//    func makeUIView(context: Context) -> WKWebView {
//        let webView = WKWebView()
//        webView.navigationDelegate = context.coordinator
//        webView.load(URLRequest(url: url))
//        return webView
//    }
//    
//    func updateUIView(_ uiView: WKWebView, context: Context) {
//        // No need to update here since navigation is handled by the user
//    }
//}
//
//struct WebViewContainer: View {
//    let url: URL
//    @State private var canGoBack = false
//    @State private var canGoForward = false
//    @State private var webView: WKWebView?
//    
//    var body: some View {
//        VStack {
//            // WebView instance
//            NewsWebView(url: url, canGoBack: $canGoBack, canGoForward: $canGoForward)
//                .onAppear {
//                    // Capture the web view instance when it is created
//                    webView = WKWebView()
//                }
//            
//            // Navigation controls
//            HStack {
//                Button(action: {
//                    webView?.goBack()
//                }) {
//                    Label("Back", systemImage: "arrow.backward")
//                }
//                .disabled(!canGoBack)
//                
//                Button(action: {
//                    webView?.goForward()
//                }) {
//                    Label("Forward", systemImage: "arrow.forward")
//                }
//                .disabled(!canGoForward)
//            }
//            .padding()
//        }
//    }
//}
