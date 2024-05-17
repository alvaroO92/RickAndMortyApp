//
//  CharacterRowView.swift
//  RickAndMortyApp
//
//  Created by Álvaro Ortí on 11/5/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct CharacterRowView: View {
    let character: Character
    
    private var characterUrl: URL? {
        URL(string: character.image ?? "")
    }
    
    var body: some View {
        
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 0)
                .fill(.white)
                .frame(height: 120)
                .shadow(color: Color(hex: "#043c6e"), radius: 2, x: 5, y: 5)
            
            HStack(spacing: 8) {
                WebImageView(url: characterUrl, placeholder: {
                    ZStack {
                        Color.gray.opacity(0.3) 
                            .edgesIgnoringSafeArea(.all)
                        
                       ProgressView().progressViewStyle(.circular)
                    }
                    .frame(width: 100, height: 120)

                }) { image in
                    image
                        .resizable()
                        .clipped()
                        .frame(width: 100, height: 120)
                        .aspectRatio(contentMode: .fill)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(character.name ?? "")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    HStack(spacing: 8) {
                        
                        if let gender = character.gender {
                            TextView(text: gender.rawValue, color: gender.color)
                        }
                        
                        if let species = character.species {
                            TextView(text: species.rawValue, color: species.color)
                        }
                        
                        if let status = character.status {
                            TextView(text: status.rawValue, color: status.color)
                        }
                    }
                }
                
                Spacer(minLength: 0)
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    private struct TextView: View {
        let text: String
        let color: String
        var body: some View {
            Text(text)
                .lineLimit(1)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(Color(hex: color))
                )
        }
    }
}
