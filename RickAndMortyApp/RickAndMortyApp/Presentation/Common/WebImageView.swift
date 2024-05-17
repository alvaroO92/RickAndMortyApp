//
//  WebImageView.swift
//  RickAndMortyApp
//
//  Created by Álvaro Ortí on 13/5/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct WebImageView<Placeholder: View, Content: View>: View {
    
    @State private var image: Image?
    
    private let url: URL?
    private let placeholder: () -> Placeholder
    private let content: (Image) -> Content
    
    init(url: URL?, placeholder: @escaping () -> Placeholder, @ViewBuilder content: @escaping (Image) -> Content) {
        self.url = url
        self.placeholder = placeholder
        self.content = content
    }
    
    var body: some View {
        Group {
            if let image = image {
                content(image)
            } else {
                placeholder()
            }
        }.onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        guard let url = url else { return }
        SDWebImageManager.shared.loadImage(with: url, context: [:], progress: nil) { uimage, _, _, _, _, _ in
            if let uimage = uimage {
                let image = Image(uiImage: uimage)
                self.image = image
            }
        }
    }
}
