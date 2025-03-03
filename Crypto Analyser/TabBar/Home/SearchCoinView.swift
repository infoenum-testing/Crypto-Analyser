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
//    @State private var coins:[Coin]?
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
            if let coins = viewModel.coins?.data.coins , !coins.isEmpty {
                ScrollView(showsIndicators: false) {
                    VStack {
                        ForEach(coins, id: \.symbol) { coin in
                            CoinRowView(coin: coin)
                                .onTapGesture {
                                    router.navigateToAuth(.searchView(symbol: coin.symbol))
                                }
                        }
                    }
                    .padding(.top,10)
                    .padding(.horizontal,20)
                }
            } else if let coins = viewModel.coins?.data.coins ,coins.isEmpty{
                VStack {
                    Spacer()
                    Text(StringConstants.noDataAvailable)
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
            viewModel.startFetching()
        }
        .onDisappear {
            viewModel.stopFetching()
        }
        .onChange(of: searchText) { value in
            if !value.isEmpty {
                viewModel.stopFetching()
                viewModel.fetchReferenceCurrencies(search: value) { result in
                    switch result {
                    case .success(let data):
                      print(data.data.coins)
                    case .failure(let error):
                        showAlert = true
                        alertMessage = "\(error.localizedDescription)"
                        print("Error fetching currencies: \(error.localizedDescription)")
                    }
                }
            } else {
                refreshUI()
                viewModel.startFetching()
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
//                coins = cryptoData.data.coins
                print(cryptoData)
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
                        Text(StringConstants.search_)
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

