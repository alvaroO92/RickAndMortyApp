//
//  CharacterDto.swift
//  RickAndMortyApp
//
//  Created by Álvaro Ortí on 10/5/24.
//

import Foundation

struct CharacterDto: Decodable {
    let id: Int
    let name: String?
    let status: String?
    let species: String?
    let gender: String?
    let image: String?
}

extension CharacterDto {
    
    public static let mock = CharacterDto(
        id: UUID().hashValue,
        name: "name",
        status: "alive",
        species: "animal",
        gender: "female",
        image: ""
    )
    
}
