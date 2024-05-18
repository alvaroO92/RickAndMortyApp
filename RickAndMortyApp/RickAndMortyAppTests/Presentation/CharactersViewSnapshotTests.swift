//
//  CharactersViewSnapshotTests.swift
//  RickAndMortyAppTests
//
//  Created by Alvaro Orti Moreno on 18/5/24.
//

import XCTest
import SwiftUI
import SnapshotTesting
@testable import RickAndMortyApp

@MainActor
final class CharactersViewSnapshotTests: XCTestCase {
   
   var sut: CharactersView!
   var viewModel: CharactersViewModel!
   let isRecord = false
   
   override func setUpWithError() throws {
      viewModel = CharactersViewModel(charactersUseCase: .mock)
      sut = CharactersView(viewModel: self.viewModel)
   }
   
   override func tearDown() async throws {
      sut = nil
      viewModel = nil
   }
   
   func testCharactersViewLoading() async throws {
      await MainActor.run {
         viewModel.send(.viewAppeared)
      }
      assertSnapshot(matching: sut, as: .image(layout: .device(config: .iPhoneX)), record: isRecord)
   }
   
   func testCharactersViewError() async throws {
      
      let viewModel = CharactersViewModel(charactersUseCase: .error)
      sut = CharactersView(viewModel: viewModel)
      
      await MainActor.run {
         viewModel.send(.viewAppeared)
      }
      
      try await Task.sleep(nanoseconds: 500_000_000)
      
      assertSnapshot(matching: sut, as: .image(layout: .device(config: .iPhoneX)), record: isRecord)
   }
   
   func testCharactersViewLoadedWithCharacters() async throws {
      await MainActor.run {
         viewModel.send(.viewAppeared)
      }
      
      try await Task.sleep(nanoseconds: 500_000_000)
      
      assertSnapshot(matching: sut, as: .image(layout: .device(config: .iPhoneX)), record: isRecord)
   }
   
   func testCharactersViewSearchFilter() async throws {
      await MainActor.run {
         viewModel.send(.viewAppeared)
      }
      
      try await Task.sleep(nanoseconds: 500_000_000)
      
      await MainActor.run {
         viewModel.send(.search("Morty"))
      }
      
      try await Task.sleep(nanoseconds: 500_000_000)
      
      assertSnapshot(matching: sut, as: .image(layout: .device(config: .iPhoneX)), record: isRecord)
   }
   
   func testCharactersViewSearchWithNoResults() async throws {
      await MainActor.run {
         viewModel.send(.viewAppeared)
      }
      
      try await Task.sleep(nanoseconds: 500_000_000)
      
      await MainActor.run {
         viewModel.send(.search("IncorrectName"))
      }
      
      try await Task.sleep(nanoseconds: 500_000_000)
      
      assertSnapshot(matching: sut, as: .image(layout: .device(config: .iPhoneX)), record: isRecord)
   }

}
