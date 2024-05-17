//
//  CharactersDto.swift
//  RickAndMortyApp
//
//  Created by Álvaro Ortí on 10/5/24.
//

import Foundation

struct CharactersDto: Decodable {
    var info: PaginationDto
    var results: [CharacterDto]
}
