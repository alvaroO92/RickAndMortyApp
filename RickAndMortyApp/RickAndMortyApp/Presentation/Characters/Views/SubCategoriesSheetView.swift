//
//  SubCategoriesSheetView.swift
//  RickAndMortyApp
//
//  Created by Álvaro Ortí on 14/5/24.
//

import SwiftUI

struct SubCategoriesSheetView: View {
    let categories: [CharactersViewModel.CharacterViewModel]
    let onTap: (CharactersViewModel.CharacterViewModel) -> Void
    
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 20) {
                ForEach(categories) { item in
                    CategoryItemView(category: item) {
                        onTap(item)
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 44)
        }
    }
}

#Preview {
    SubCategoriesSheetView(categories: [.init(text: "Gender", colorString: "")], onTap: {_ in })
}
