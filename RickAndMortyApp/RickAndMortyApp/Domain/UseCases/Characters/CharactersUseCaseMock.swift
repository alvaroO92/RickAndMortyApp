//
//  CharactersUseCaseMock.swift
//  RickAndMortyApp
//
//  Created by Álvaro Ortí on 11/5/24.
//

import Foundation

extension CharactersUseCase {
   
   public static let mock = Self(
      getCharacters: { page in
         let repository = CharactersRespository.mock
         let result = try await repository.getCharacters(page)
         return Characters.from(charactersDto: result)
      }
   )
}
