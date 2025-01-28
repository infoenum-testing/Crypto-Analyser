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
                        .foregroundColor(.black)
                })
                searchBarView
            }
            .padding(.horizontal, 20)
            if let coins , !coins.isEmpty{
                ScrollView(showsIndicators: false) {
                    ForEach(coins, id: \.symbol) { coin in
                        CoinRowView(coin: coin)
                            .onTapGesture {
                                router.navigateToAuth(.searchView(symbol: coin.symbol))
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
                    Spacer()
                }
            }
        }
        .onAppear {
            searchText = ""
            refreshUI()
        }
        .onChange(of: searchText) { value in
            if !value.isEmpty {
                viewModel.fetchReferenceCurrencies(search: value) { result in
                    switch result {
                    case .success(let currencies):
                        coins = currencies.map { from(currency: $0) }
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
                    .foregroundColor(Color.gray)
                    .frame(width: 18, height: 18)
                    .padding(.horizontal,5)
                TextField("Search...", text: $searchText)
                //              .focused($isTextFieldFocused)
                    .autocorrectionDisabled()
                if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "multiply.circle")
                            .resizable()
                            .foregroundColor(Color.gray)
                            .frame(width: 18, height: 18)
                            .padding(.horizontal,5)
                    }
                }
            }.padding(8)
        }.background(Color(.systemGray6))
            .cornerRadius(10)
    }
    
    func from(currency: Currency) -> Coin {
        return Coin(
            uuid: currency.uuid,
            symbol: currency.symbol,
            name: currency.name,
            color: nil,  // No corresponding value in Currency
            iconURL: currency.iconUrl,
            marketCap: nil, // No corresponding value
            price: nil, // No corresponding value
            listedAt: nil, // No corresponding value
            tier: nil, // No corresponding value
            change: nil, // No corresponding value
            rank: nil, // No corresponding value
            sparkline: nil, // No corresponding value
            lowVolume: nil, // No corresponding value
            coinRankingURL: nil, // No corresponding value
            btcPrice: nil, // No corresponding value
            contractAddresses: nil // No corresponding value
        )
    }
}

#Preview {
    SearchCoinView()
}

struct CoinRowView: View {
    let coin:Coin
    var body: some View {
        
        VStack{
            HStack {
                ZStack {
                    HStack {
                        AsyncImage(url: URL(string: coin.iconURL)) { image in
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
                .padding(.trailing,20)
                VStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(coin.symbol)
                        //                            .font(.Roboto(size: 16, weight: .semibold ))
                        //                            .foregroundColor(.appBlackColor)
                            .padding(.bottom,5)
                        Text(coin.name)
                        //                            .font(.Roboto(size: 14, weight: .regular))
                            .foregroundColor(.black).opacity(0.5)
                    }
                    .padding(.top,5)
                }.frame(height: 50)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.vertical,5)
        }
        .frame(height: 55)
        .background(.white)
        .cornerRadius(16)
        .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 4)
        
    }
}
