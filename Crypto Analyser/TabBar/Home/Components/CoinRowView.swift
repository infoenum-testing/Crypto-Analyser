//
//  CoinRowView.swift
//  Crypto Analyser
//
//  Created by IE15 on 10/02/25.
//

import SwiftUI

struct CoinRowView: View {
    let coin:Coin
    @State private var isLoading = true
    var body: some View {
        VStack {
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
        .background(.cellcolortheme)
        .cornerRadius(16)
    }
}

