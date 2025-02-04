//
//  CrytoNewsView.swift
//  Crypto Analyser
//
//  Created by IE15 on 21/12/24.
//

import SwiftUI
import WebKit

struct CryptoNewsView: View {
    @StateObject var viewModel = CryptoNewsViewModel()
    @State private var newsData:[NewsDetails] = []
    @State private var newsLoading:Bool = false
    @State private var pageIndex:Int = 1
    @State private var isLast:Bool = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State  var showWebView:Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing:1) {
            Text("Crypto News")
                .foregroundStyle(.white)
                .font(.system(size: 25, weight: .semibold))
                .padding(.leading,20)
            if newsLoading &&  (newsData.count == 0){
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        ProgressView()
                            .controlSize(.large)
                            .foregroundColor(.white)
                            .tint(Color.pink)
                        Spacer()
                    }
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading,spacing:15) {
                        ForEach(newsData.indices, id: \.self) { index in
                            let news = newsData[index]
                            newsCellView(imageUrl: news.imageUrl ?? "", title: news.title ?? "", newsUrl: news.newsUrl ?? "", des: news.text ?? "", newsUrlAction: {
                                if let urlStr = news.newsUrl {
                                    viewModel.selectedNewsUrl = urlStr
                                    if !viewModel.selectedNewsUrl.isEmpty{
                                        showWebView = true
                                    }
                                }
                            })
                           
                            .onAppear {
                                if (newsData.count - 1) == index && !isLast{
                                    pageIndex += 1
                                    fetchData(page: pageIndex)
                                }
                            }
                        }
                    }
                    .padding(.horizontal,20)
                    .padding(.top,15)
                }
            }
        }
        .background(Color.themecolor)
        .fullScreenCover(isPresented: $showWebView, content: {
            NewsWebView(urlString:  viewModel.selectedNewsUrl)
                .edgesIgnoringSafeArea(.all)
            
        })
        .onAppear {
            fetchData(page: pageIndex)
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
                isLast = newsArray.isEmpty
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
    var newsUrlAction:() -> Void
    var body: some View {
        VStack(alignment: .leading) {
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
                        newsUrlAction()
                    }
                    .padding(5)
                    .frame(maxWidth: .infinity)
            }
            Text(des)
                .foregroundStyle(.white)
        }
        .padding(8)
        .background(Color.cellcolor)
        .cornerRadius(8)
    }
}

