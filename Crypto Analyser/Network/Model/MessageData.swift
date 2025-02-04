//
//  ReferenceCurrencyResponse.swift
//  Crypto Analyser
//
//  Created by IE15 on 27/01/25.
//

import Foundation

struct MessageData: Codable {
    let signal: String?
    let techAnalysis: String?
    let confidenceLevel: String?
    
    enum CodingKeys: String, CodingKey {
        case signal
        case techAnalysis = "tech_analysis"
        case confidenceLevel = "confidence_level"
    }
}
