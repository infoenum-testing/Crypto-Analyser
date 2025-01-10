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
    @State private var newsLoading:Bool = false
    @State private var pageIndex:Int = 1
    @State private var showAlert = false
    @State private var alertMessage = ""
    var body: some View {
        VStack(spacing:1) {
            Text("Crypto News")
                .font(.system(size: 25, weight: .semibold))
            if newsLoading &&  newsData.count == 0{
                VStack {
                    Spacer()
                    ProgressView()
                        .controlSize(.large)
                        .foregroundColor(.white)
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing:15) {
                        ForEach(newsData.indices, id: \.self) { index in
                            let news = newsData[index]
                            newsCellView(imageUrl: news.imageUrl ?? "", title: news.title ?? "", newsUrl: news.newsUrl ?? "", des: news.text ?? "")
                                .onAppear {
//                                    if pageIndex < 20 {
//                                        pageIndex += 1
//                                        fetchData(page: pageIndex)
//                                    }
                                }
                        }
                    }
                    .padding(.horizontal,20)
                    .padding(.top,15)
                }
            }
        } .onAppear {
//            fetchData(page: pageIndex)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(StringConstants.error),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"), action: {})
            )
        }
    }
    
    private func fetchData(page:Int) {
        newsLoading = true
        fetchCryptoNews(page:page) { result in
            newsLoading = false
            switch result {
            case .success(let newsArray):
                newsData += newsArray
            case .failure(let error):
                showAlert = true
                alertMessage = error.localizedDescription
                print("Error fetching news: \(error)")
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
                WebViewContainer(url: url)
                    .edgesIgnoringSafeArea(.all)
            } else {
                Text("Invalid URL")
            }
        }
    }
}

