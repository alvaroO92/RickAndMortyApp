//
//  SearchBarView.swift
//  RickAndMortyApp
//
//  Created by Álvaro Ortí on 12/5/24.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    @State private var typingText: String = "" // internal value 
    
    var body: some View {
        HStack {
            TextField("Buscar...", text: $typingText)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if !typingText.isEmpty {
                            Button(action: {
                                self.typingText = ""
                                self.text = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
                .padding(.horizontal, 10)
                .onChange(of: typingText) { newValue in
                    self.text = newValue
                }
        }
    }
}

#Preview {
    SearchBarView(text: .constant("text"))
}
