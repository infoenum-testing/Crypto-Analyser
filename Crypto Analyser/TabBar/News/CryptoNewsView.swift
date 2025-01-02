//
//  CrytoNewsView.swift
//  Crypto Analyser
//
//  Created by IE15 on 21/12/24.
//

import SwiftUI
import WebKit

struct CryptoNewsView: View {
    @State private var newsData:[NewsDetails] = []
    var body: some View {
        VStack(spacing:1) {
            Text("Crypto News")
                .font(.system(size: 30, weight: .semibold))
            
            ScrollView {
                LazyVStack(spacing:15) {
                    ForEach(newsData.indices, id: \.self) { index in
                        let news = newsData[index]
                        newsCellView(imageUrl: news.imageUrl ?? "", title: news.title ?? "", newsUrl: news.newsUrl ?? "", des: news.text ?? "")
                    }
                }
                .padding(.horizontal,20)
                .padding(.top,15)
            }
        } .onAppear {
            if let news = decodeNewsJson() {
                newsData = news
            }
        }
    }
}

#Preview {
    CryptoNewsView()
}

struct newsCellView: View {
    let imageUrl: String
    let title: String
    let newsUrl: String
    let des: String
    @State private var showWebView = false

    var body: some View {
        VStack {
            HStack(alignment: .top) {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray
                }
                .frame(width: 150, height: 100)
                .clipShape(.rect(cornerRadius: 0))
                
                Text(title)
                    .foregroundStyle(.orange)
                    .onTapGesture {
                        showWebView = true
                    }
            }
            Text(des)
        }
        .padding(5)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
        .sheet(isPresented: $showWebView) {
            if let url = URL(string: newsUrl) {
                WebViewContainer(url: url, title: "")
                    .edgesIgnoringSafeArea(.all)
            } else {
                Text("Invalid URL")
            }
        }
    }
}

//struct WebView: UIViewRepresentable {
//    let url: URL
//    @Binding var canGoBack: Bool
//    @Binding var canGoForward: Bool
//    
//    class Coordinator: NSObject, WKNavigationDelegate {
//        var parent: WebView
//        
//        init(parent: WebView) {
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
//            WebView(url: url, canGoBack: $canGoBack, canGoForward: $canGoForward)
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
