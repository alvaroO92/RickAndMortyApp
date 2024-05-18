//
//  CharactersRespositoryTests.swift
//  RickAndMortyAppTests
//
//  Created by Alvaro Orti Moreno on 18/5/24.
//

import XCTest
@testable import RickAndMortyApp

final class CharactersRepositoryTests: XCTestCase {
   var sut: CharactersRespository!

    override func setUpWithError() throws {
       sut = CharactersRespository.mock
    }

    override func tearDownWithError() throws {
        sut = nil
    }


   func testGetCharacters() async throws {
      let expectedCharacter = CharacterDto(id: 1, name: "Rick Sanchez", status: "alive", species: "human", gender: "male", image: "https://rickandmortyapi.com/api/character/avatar/5.jpeg")
      let characters = try await sut.getCharacters(1)
      
      XCTAssertTrue(characters.results.count > 0)
      XCTAssertEqual(characters.results.first, expectedCharacter)
   }

}
