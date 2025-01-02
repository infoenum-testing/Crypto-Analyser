//
//  EntitlementManager.swift
//  Crypto Analyser Dev
//
//  Created by IE MacBook Pro 2014 on 02/01/25.
//

import Foundation
import SwiftUI

class EntitlementManager: ObservableObject {
    static let userDefaults = UserDefaults(suiteName: "Crypto.Analyser.app")!
    
    @AppStorage("hasPro", store: userDefaults)
    var hasPro: Bool = false
}

