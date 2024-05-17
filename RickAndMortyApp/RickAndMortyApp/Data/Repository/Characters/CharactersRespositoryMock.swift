//
//  CharactersRespositoryMock.swift
//  RickAndMortyApp
//
//  Created by Álvaro Ortí on 10/5/24.
//

import Foundation

extension CharactersRespository {
    
    public static let mock = Self(
        getCharacters: { page in
                .init(info: .init(pages: 1, count: 1, next: ""), results: [.mock])
        }
    )
}
