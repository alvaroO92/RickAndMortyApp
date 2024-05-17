//
//  CharactersUseCaseLive.swift
//  RickAndMortyApp
//
//  Created by Álvaro Ortí on 11/5/24.
//

import Foundation

extension CharactersUseCase {
   
   public static let live = Self(
      getCharacters: { page in
         let repository = CharactersRespository.live
         let result = try await repository.getCharacters(page)
         return Characters.from(charactersDto: result)
      }
   )
}
