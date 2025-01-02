//
//  IAP Constants.swift
//  Crypto Analyser Dev
//
//  Created by IE MacBook Pro 2014 on 02/01/25.
//

import Foundation
struct IAPConstants {
    
    // MARK: - Product Identifiers
    struct Products {
        static let monthlySubscription = "com.infoenum.Crypto.autoRenewableOneMonth"
        static let yearlySubscription = "com.infoenum.Crypto.autoRenewableOneYear"
        
        static let all: Set<String> = [
            monthlySubscription,
            yearlySubscription
        ]
    }
}


