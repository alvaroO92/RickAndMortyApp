//
//  CategoryItemView.swift
//  RickAndMortyApp
//
//  Created by Álvaro Ortí on 13/5/24.
//

import SwiftUI

struct CategoryItemView: View {

    let category: CharactersViewModel.CharacterViewModel
    var onTap: () -> Void

      var body: some View {
          Text(category.text)
              .lineLimit(1)
              .minimumScaleFactor(0.6)
              .padding()
              .frame(minWidth: 50, maxWidth: .infinity)
              .background(Color(hex: category.colorString))
              .foregroundColor(.white)
              .cornerRadius(8)
              .onTapGesture {
                  onTap()
              }
      }
}

#Preview {
    CategoryItemView(category: .init(text: "Gender", colorString: ""), onTap: {})
}
