//
//  CryptoResponse.swift
//  Crypto Analyser
//
//  Created by IE15 on 27/01/25.
//
import Foundation

// Root response model
struct CryptoResponse: Codable {
    let status: String
    let data: CryptoData

    enum CodingKeys: String, CodingKey {
        case status
        case data
    }
}

// Crypto data model (Reusing existing Stats class)
struct CryptoData: Codable {
    let stats: Stats  // Using your existing Stats class
    let coins: [Coin]

    enum CodingKeys: String, CodingKey {
        case stats
        case coins
    }
}

// Coin model
struct Coin: Codable {
    let uuid: String?
    let symbol: String
    let name: String
    let color: String?
    let iconURL: String
    let marketCap: String?
    let price: String?
    let listedAt: Int?
    let tier: Int?
    let change: String?
    let rank: Int?
    let sparkline: [String?]?
    let lowVolume: Bool?
    let coinRankingURL: String?
    let btcPrice: String?
    let contractAddresses: [String]?

    enum CodingKeys: String, CodingKey {
        case uuid
        case symbol
        case name
        case color
        case iconURL = "iconUrl"
        case marketCap
        case price
        case listedAt
        case tier
        case change
        case rank
        case sparkline
        case lowVolume
        case coinRankingURL = "coinrankingUrl"
        case btcPrice
        case contractAddresses
    }
}

struct Stats: Codable {

    let total: Int
    let totalCoins: Int
    let totalMarkets: Int
    let totalExchanges: Int
    let totalMarketCap: String
    let total24hVolume: String

}

struct APIErrorResponse: Codable {
    let status: String
    let code: String?
    let message: String?
}
