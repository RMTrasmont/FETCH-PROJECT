//
//  BackgroundCanvasView.swift
//  FetchRecipes
//
//  Created by RMT on 5/26/25.
//

import SwiftUI

struct BackgroundPatternView: View {
    var body: some View {
        
        VStack(spacing:0) {
            PatternView()
            PatternView()
                .offset(y: 70)
            PatternView()
                .offset(y: 140)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    BackgroundPatternView()
}

private struct PatternView: View {
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 70) {
                
                HStack(spacing: 70){
                    ForEach(0..<5, id: \.self) { _ in
                        Image(systemName: "dog").fontWeight(.heavy).scaleEffect(3)
                        Image(systemName: "star").fontWeight(.heavy).scaleEffect(3)
                    }
                    
                }
                
                
                HStack(spacing: 70){
                    ForEach(0..<5, id: \.self) { _ in
                        Image(systemName: "dice").fontWeight(.heavy).scaleEffect(3)
                        Image(systemName: "wineglass").fontWeight(.heavy).scaleEffect(3)
                    }
                    
                }
                .offset(x:35)
                
                HStack(spacing: 70){
                    ForEach(0..<5, id: \.self) { _ in
                        Image(systemName: "heart").fontWeight(.heavy).scaleEffect(3)
                        Image(systemName: "gamecontroller").fontWeight(.heavy).scaleEffect(3)
                    }
                   
                }
                
                HStack(spacing: 70){
                    ForEach(0..<5, id: \.self) { _ in
                        Image(systemName: "birthday.cake").fontWeight(.heavy).scaleEffect(3)
                        Image(systemName: "fork.knife").fontWeight(.heavy).scaleEffect(3)
                    }
                    
                }
                .offset(x:35)
                
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .frame(height: 300)
            .foregroundStyle(Color.pink.opacity(0.1))
            
            
        }
        .ignoresSafeArea()
    }
    
}
