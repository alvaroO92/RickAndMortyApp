//
//  CharactersUseCase.swift
//  RickAndMortyApp
//
//  Created by Álvaro Ortí on 11/5/24.
//

import Foundation

public struct CharactersUseCase {
    var getCharacters: (_ page: Int) async throws -> Characters

    init(
        getCharacters: @escaping (_ page: Int) async throws -> Characters
    ) {
        self.getCharacters = getCharacters
    }
}
