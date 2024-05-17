//
//  CharactersRespositoryLive.swift
//  RickAndMortyApp
//
//  Created by Álvaro Ortí on 10/5/24.
//

import Foundation

extension CharactersRespository {
    public static let live = Self(
        getCharacters: { page in
            try await Network().customRequest(
                endPoint: CharactersDatasource().getCharacters(page: page),
                type: CharactersDto.self
            )
        }
    )
}
