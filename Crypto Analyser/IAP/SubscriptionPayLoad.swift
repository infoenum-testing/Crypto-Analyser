//
//  SubscriptionPayLoad.swift
//  Crypto Analyser Dev
//
//  Created by IE MacBook Pro 2014 on 03/01/25.
//

import Foundation

struct SubscriptionPayload: Codable {
    let transactionId: String?
    let originalTransactionId: String?
    let subscriptionStartDate: String?
    let subscriptionEndDate: String?
    let productId: String?
}
