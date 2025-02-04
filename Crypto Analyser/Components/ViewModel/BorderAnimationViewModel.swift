//
//  BorderAnimationViewModel.swift
//  Crypto Analyser Dev
//
//  Created by IE15 on 30/01/25.
//

import Foundation
import SwiftUI

class BorderAnimationViewModel:ObservableObject {
    @Published  var animate = false
    @Published  var gradientColors: [Color] = [.pink, .purple, .blue]
    @Published  var timer: Timer?
    
  
    // Start Animation
    func startColorAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 1)) {
                self.gradientColors = self.gradientColors.shuffled() // Change order of colors
            }
        }
    }
    
    // Stop Animation
    func stopColorAnimation() {
        timer?.invalidate()
        timer = nil
    }
}
