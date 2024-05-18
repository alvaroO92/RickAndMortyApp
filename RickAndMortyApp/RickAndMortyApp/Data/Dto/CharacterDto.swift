//
//  CharacterDto.swift
//  RickAndMortyApp
//
//  Created by Álvaro Ortí on 10/5/24.
//

import Foundation

struct CharacterDto: Codable, Equatable {
    let id: Int
    let name: String?
    let status: String?
    let species: String?
    let gender: String?
    let image: String?
}
