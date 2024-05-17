//
//  SplashScreenView.swift
//  RickAndMortyApp
//
//  Created by Álvaro Ortí on 12/5/24.
//

import SwiftUI

struct SplashScreenView<Content: View>: View {
    let content: () -> Content
    let splashScreenImage: () -> Image
    
    @State private var showContent = false
    @State private var animateImage = true
    
    var body: some View {
        ZStack {
            if showContent {
                content()
            } else {
                splashScreenImage()
                    .scaleEffect(animateImage ? 0 : 1) // Zoom in
                    .animation(
                        Animation
                            .bouncy(duration: 1)
                            .repeatCount(2, autoreverses: true),
                        value: animateImage
                    )
            }
        }
        
        .onAppear {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    self.animateImage = false
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    self.showContent = true
                }
            }
        }
    }
}
