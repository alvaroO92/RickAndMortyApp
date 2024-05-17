//
//  CharactersRespository.swift
//  RickAndMortyApp
//
//  Created by Álvaro Ortí on 10/5/24.
//

import Foundation

public struct CharactersRespository {
    var getCharacters: (_ page: Int) async throws -> CharactersDto
    
    init(getCharacters: @escaping (_ page: Int) async throws -> CharactersDto) {
        self.getCharacters = getCharacters
    }
}
