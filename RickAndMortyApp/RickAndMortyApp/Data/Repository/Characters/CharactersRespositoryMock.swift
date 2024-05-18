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
                .init(info: .init(pages: 1, count: 1, next: ""), results: [
                  CharacterDto(id: 1, name: "Rick Sanchez", status: "alive", species: "human", gender: "male", image: "https://rickandmortyapi.com/api/character/avatar/5.jpeg"),
                  CharacterDto(id: 2, name: "Morty Smith", status: "alive", species: "human", gender: "male", image: "https://rickandmortyapi.com/api/character/avatar/5.jpeg")
              ])
        }
    )
}
