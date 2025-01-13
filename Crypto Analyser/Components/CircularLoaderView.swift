//
//  CircularLoaderView.swift
//  Crypto Analyser
//
//  Created by IE15 on 26/12/24.
//

import SwiftUI

struct LeafLoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // This ZStack holds the rotating LeafShapes
            ForEach(0..<15) { index in
                LeafShape()
                    .fill(Color.black.opacity(Double(index) / 15.0))
                    .frame(width: 15, height: 40)
                    .foregroundColor(.gray.opacity(12.0 / Double(index)))
                    .offset(y: -65)
                    .rotationEffect(.degrees(Double(index) * (360 / 15)))
            }
            .frame(width: 150, height: 150)
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            .animation(
                Animation.linear(duration: 2)
                    .repeatForever(autoreverses: false),
                value: isAnimating
            )
            
            Text("Analysing...")
                .foregroundStyle(.black)
                .font(.system(size: 15, weight: .semibold))
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct LeafShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Move to the top center point
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        
        // Draw the left curve with a sharp top and bottom
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.midY),
                          control: CGPoint(x: rect.minX, y: rect.minY))
        
        // Draw the bottom curve with symmetry to the top
        path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.maxY),
                          control: CGPoint(x: rect.midX - rect.width * 0.1, y: rect.maxY))
        
        // Draw the right curve with symmetry to the left
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.midY),
                          control: CGPoint(x: rect.maxX, y: rect.maxY))
        
        // Draw the top curve with symmetry to the bottom
        path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.minY),
                          control: CGPoint(x: rect.midX + rect.width * 0.1, y: rect.minY))
        
        return path
    }
}

#Preview {
    LeafLoadingView()
}
