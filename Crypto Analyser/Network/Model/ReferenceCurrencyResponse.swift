//
//  ReferenceCurrencyResponse.swift
//  Crypto Analyser
//
//  Created by IE15 on 27/01/25.
//

import Foundation
struct ReferenceCurrencyResponse: Codable {
    let status: String
    let data: CurrencyData
}

struct CurrencyData: Codable {
    let stats: Stats
    let currencies: [Currency]
}

struct Stats: Codable {
    let total: Int
}

struct Currency: Codable {
    let uuid: String
    let type: String
    let iconUrl: String
    let name: String
    let symbol: String
    let sign: String?
}
