//
//  SearchCoinView.swift
//  Crypto Analyser
//
//  Created by IE15 on 28/01/25.
//

import SwiftUI

struct SearchCoinView: View {
    @EnvironmentObject var router: Router
    @StateObject var viewModel = SearchViewModel()
    @State private var coins:[Coin]?
    @State private var searchText = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    router.navigateBackInAuth()
                }, label: {
                    Image(.back)
                        .foregroundColor(.white)
                })
                searchBarView
                    .padding(.leading,5)
            }
            .padding(.horizontal, 20)
            if let coins , !coins.isEmpty{
                ScrollView(showsIndicators: false) {
                    VStack {
                        ForEach(coins, id: \.symbol) { coin in
                            CoinRowView(coin: coin)
                                .onTapGesture {
                                    router.navigateToAuth(.searchView(symbol: coin.symbol))
                                }
                        }
                    }
                    .padding(.top,2)
                    .padding(.horizontal,20)
                }
            } else if let coins ,coins.isEmpty{
                VStack {
                    Spacer()
                    Text("No Data Availble")
                    Spacer()
                }
            } else {
                VStack {
                    Spacer()
                    ProgressView()
                        .controlSize(.large)
                        .foregroundColor(.white)
                        .tint(Color.pink)
                    Spacer()
                }
            }
        }
        .background(Color.themecolor)
        .onAppear {
            searchText = ""
            refreshUI()
        }
        .onChange(of: searchText) { value in
            if !value.isEmpty {
                viewModel.fetchReferenceCurrencies(search: value) { result in
                    switch result {
                    case .success(let data):
                        coins = data.data.coins
                    case .failure(let error):
                        showAlert = true
                        alertMessage = "\(error.localizedDescription)"
                        print("Error fetching currencies: \(error.localizedDescription)")
                    }
                }
            } else {
                refreshUI()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(StringConstants.validationErrorTitle), message: Text(alertMessage), dismissButton: .default(Text(StringConstants.oKText)))
        }
    }
    private func refreshUI() {
        viewModel.fetchCryptoData { result in
            switch result {
            case .success(let cryptoData):
                coins = cryptoData.data.coins
            case .failure(let error):
                showAlert = true
                alertMessage = "\(error.localizedDescription)"
                print("Error fetching data: \(error.localizedDescription)")
            }
        }
    }
    private var searchBarView: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .foregroundColor(Color.white)
                    .frame(width: 18, height: 18)
                    .padding(.horizontal,5)
                TextField("", text: $searchText)
                    .autocorrectionDisabled()
                    .accentColor(.white)
                    .foregroundColor(.white)
                    .placeholder(when: $searchText.wrappedValue.isEmpty) {
                        Text("Search...")
                            .foregroundColor(.gray)
                    }
                if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "multiply.circle")
                            .resizable()
                            .foregroundColor(Color.white)
                            .frame(width: 18, height: 18)
                            .padding(.horizontal,5)
                    }
                }
            }.padding(8)
        }.background(Color(.cellcolor))
            .cornerRadius(10)
    }

}

#Preview {
    SearchCoinView()
}

struct CoinRowView: View {
    let coin:Coin
    @State private var isLoading = true
    var body: some View {
        VStack{
            HStack {
                HStack {
                    if let url = URL(string: coin.iconURL) {
                               if url.pathExtension.lowercased() == "svg" {
                                   ZStack {
                                       SVGWebView(url: url, isLoading: $isLoading)
                                           .frame(width: 45, height: 45)
                                           .clipShape(Circle())
                                       
                                       if isLoading {
                                           ZStack {
                                               Color.gray
                                               ProgressView()
                                           }
                                           .frame(width: 45, height: 45)
                                           .clipShape(Circle())
                                       }
                                   }
                               } else {
                                   AsyncImage(url: url) { image in
                                       image.resizable()
                                   } placeholder: {
                                       ZStack {
                                           Color.gray
                                           ProgressView()
                                       }
                                   }
                                   .scaledToFill()
                                   .frame(width: 45, height: 45)
                                   .clipShape(Circle())
                               }
                           }
                       }
                       .padding(.trailing, 10)
                VStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(coin.name)
                            .foregroundStyle(.white)
                            .padding(.bottom,5)
                            .font(.system(size: 17, weight: .semibold))
                        Text(coin.symbol)
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .regular))
                    }
                    .padding(.top,5)
                }.frame(height: 50)
                Spacer()
                if let priceStr = coin.price,let price = Double(priceStr) {
                    let formattedStr = price >= 1 ? String(format: "%.2f", price) : String(format: "%.7f", price)
                    VStack(alignment: .trailing,spacing:2) {
                        HStack(spacing:3) {
                            Text("$")
                                .foregroundStyle(.white)
                                .padding(.bottom,5)
                                .font(.system(size: 18, weight: .semibold))
                            
                            Text(formattedStr)
                                .foregroundStyle(.blue)
                                .padding(.bottom,5)
                                .font(.system(size: 18, weight: .semibold))
                        }
                        if let change = coin.change ,let price = Double(change){
                            Text(change)
                                .foregroundStyle(price < 0 ? .red : .green)
                                .font(.system(size: 18, weight: .semibold))
                                .multilineTextAlignment(.trailing)
                                 
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical,5)
        }
        .frame(height: 60)
        .background(.cellcolor)
        .cornerRadius(16)
    }
}

