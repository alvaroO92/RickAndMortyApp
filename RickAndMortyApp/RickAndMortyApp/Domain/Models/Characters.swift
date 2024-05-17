//
//  Characters.swift
//  RickAndMortyApp
//
//  Created by Álvaro Ortí on 11/5/24.
//

import Foundation

struct Characters {
    var hasMorePages: Bool
    var characters: [Character]
}

extension Characters {
   
   public static func from(charactersDto: CharactersDto) -> Self {
      Characters(
          hasMorePages: charactersDto.info.hasNext,
          characters: charactersDto.results.compactMap { Character.from(charactersDto: $0)}
      )
   }

}
