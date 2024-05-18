//
//  CharactersUseCaseTests.swift
//  RickAndMortyAppTests
//
//  Created by Alvaro Orti Moreno on 18/5/24.
//

import XCTest
@testable import RickAndMortyApp

final class CharactersUseCaseTests: XCTestCase {
   var sut: CharactersUseCase!

    override func setUpWithError() throws {
       sut = CharactersUseCase.mock
    }

    override func tearDownWithError() throws {
        sut = nil
    }

   func testGetCharacters() async throws {
      
      let characters = try await sut.getCharacters(1)
      
      XCTAssertTrue(characters.characters.count > 0)
      XCTAssertEqual(characters.characters.first?.name, "Rick Sanchez")
   }

}

