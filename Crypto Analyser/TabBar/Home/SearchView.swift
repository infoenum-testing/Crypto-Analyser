//
//  SearchView.swift
//  Crypto Analyser
//
//  Created by IE15 on 26/12/24.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var router: Router
    @State private var searchText = ""
    @State private var showCancelButton: Bool = false
    let cryptoSuggestions = [
        "Bitcoin (BTC)",
        "Ethereum (ETH)",
        "Binance Coin (BNB)",
        "Tether (USDT)",
        "Cardano (ADA)",
        "Solana (SOL)",
        "Ripple (XRP)",
        "Polkadot (DOT)",
        "Dogecoin (DOGE)",
        "Litecoin (LTC)",
        "Chainlink (LINK)",
        "Stellar (XLM)",
        "Uniswap (UNI)",
        "Avalanche (AVAX)",
        "Shiba Inu (SHIB)",
        "USD Coin (USDC)",
        "Terra (LUNA)",
        "VeChain (VET)",
        "Tron (TRX)",
        "Cosmos (ATOM)"
    ]
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    router.navigateBackInAuth()
                }, label: {
                    Image(.back)
                        .foregroundColor(.black)
                })
                Spacer()
            }
            .padding(.horizontal,20)
            
            HStack {
                Image(systemName: "magnifyingglass")
                
                TextField("search", text: $searchText, onEditingChanged: { isEditing in
                    self.showCancelButton = true
                }, onCommit: {
                    print("onCommit")
                }).foregroundColor(.primary)
                    .accentColor(.black)
                
                Button(action: {
                    self.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill").opacity(searchText == "" ? 0 : 1)
                }
            }
            .padding(EdgeInsets(top: 10, leading: 6, bottom: 10, trailing: 6))
            .foregroundColor(.secondary)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10.0)
            .padding(.horizontal,20)
            let filteredSuggestions = cryptoSuggestions.filter { $0.lowercased().contains(searchText.lowercased()) }
            if !filteredSuggestions.isEmpty {
                ScrollView {
                    ForEach(0..<filteredSuggestions.count, id: \.self) { index in
                        VStack(alignment: .leading,spacing: 0) {
                            HStack {
                                Text(filteredSuggestions[index])
                                    .foregroundStyle(.black)
                                    .font(.system(size: 18, weight: .regular))
                                Spacer()
                            }
                            .padding(.horizontal,20)
                        }
                        .padding(.vertical,4)
                        .background(Color.white)
                        .cornerRadius(8)
                        .foregroundColor(.black)
                        .font(.system(size: 20))
                        .onTapGesture {
                            router.navigateToAuth(.dataDescription(afterAnalyse: false, title: "", message: ""))
                        }
                    }
                }
            } else if searchText != "" {
                VStack {
                    Spacer()
                    Text("No Data Found")
                    Spacer()
                }
            } else {
                Spacer()
            }
        }
    }
}

#Preview {
    SearchView()
}
