//
//  CharactersViewModelTests.swift
//  RickAndMortyAppTests
//
//  Created by Alvaro Orti Moreno on 18/5/24.
//

import XCTest
@testable import RickAndMortyApp

@MainActor
final class CharactersViewModelTests: XCTestCase {
    var sut: CharactersViewModel!

    override func setUpWithError() throws {
        sut = CharactersViewModel(charactersUseCase: .mock)
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testInitialLoad() async {
        await MainActor.run {
            XCTAssertEqual(sut.state, .loading)
        }

        sut.send(.viewAppeared)

        try? await Task.sleep(nanoseconds: 500_000_000)

        await MainActor.run {
            guard case let .loaded(state) = sut.state else {
                return XCTFail("State should be loaded")
            }

            XCTAssertEqual(state.characters.count, 2)
            XCTAssertEqual(state.characters.first?.name, "Rick Sanchez")
        }
    }

    func testLoadMore() async {
        sut.send(.viewAppeared)

        try? await Task.sleep(nanoseconds: 500_000_000)

        await MainActor.run {
            XCTAssertEqual(sut.state.loadedState?.characters.count, 2)
        }

        sut.send(.loadMore)

        try? await Task.sleep(nanoseconds: 500_000_000)

        await MainActor.run {
            XCTAssertEqual(sut.state.loadedState?.characters.count, 4)
        }
    }

    func testSearch() async {
        sut.send(.viewAppeared)

        try? await Task.sleep(nanoseconds: 500_000_000)

        sut.send(.search("Morty"))

        try? await Task.sleep(nanoseconds: 500_000_000)

        await MainActor.run {
            guard case let .loaded(state) = sut.state else {
                return XCTFail("State should be loaded")
            }

            XCTAssertEqual(state.characters.count, 1)
            XCTAssertEqual(state.characters.first?.name, "Morty Smith")
        }
    }

    func testCategoryTapped() async {
        sut.send(.viewAppeared)

        try? await Task.sleep(nanoseconds: 500_000_000)

        sut.send(.categoryTapped("Gender"))

        try? await Task.sleep(nanoseconds: 500_000_000)

        await MainActor.run {
            guard case let .loaded(state) = sut.state else {
                return XCTFail("State should be loaded")
            }

            XCTAssertEqual(state.subCategories?.count, Character.Gender.allCases.count)
        }
    }

    func testToggleCategorySelection() async {
        sut.send(.viewAppeared)

        try? await Task.sleep(nanoseconds: 500_000_000)

        sut.send(.toggleCategorySelection("Gender"))

        try? await Task.sleep(nanoseconds: 500_000_000)

        await MainActor.run {
            guard case let .loaded(state) = sut.state else {
                return XCTFail("State should be loaded")
            }

            XCTAssertTrue(state.categories.first { $0.text == "Gender" }?.isSelected ?? false)
        }
    }

    func testSubCategorySelectionMarksCategory() async {
        sut.send(.viewAppeared)

        try? await Task.sleep(nanoseconds: 500_000_000)

        await MainActor.run {
            sut.send(.categoryTapped("Gender"))
        }

        try? await Task.sleep(nanoseconds: 500_000_000)

        await MainActor.run {
            sut.send(.subCategoryTapped(CharactersViewModel.CharacterViewModel(text: "Male", colorString: "#02afc5", parent: .gender)))
        }

        try? await Task.sleep(nanoseconds: 500_000_000)

        await MainActor.run {
            guard case let .loaded(state) = sut.state else {
                return XCTFail("State should be loaded")
            }

            XCTAssertTrue(state.categories.first { $0.text == "Gender" }?.isSelected ?? false)
        }
    }

    func testRefreshResetsCategories() async {
        sut.send(.viewAppeared)

        try? await Task.sleep(nanoseconds: 500_000_000)

        await MainActor.run {
            sut.send(.categoryTapped("Gender"))
        }

        try? await Task.sleep(nanoseconds: 500_000_000)

        await MainActor.run {
            sut.send(.subCategoryTapped(CharactersViewModel.CharacterViewModel(text: "Male", colorString: "#02afc5", parent: .gender)))
        }

        try? await Task.sleep(nanoseconds: 500_000_000)

        await MainActor.run {
            sut.send(.refresh)
        }

        try? await Task.sleep(nanoseconds: 500_000_000)

        await MainActor.run {
            guard case let .loaded(state) = sut.state else {
                return XCTFail("State should be loaded")
            }

            XCTAssertTrue(state.categories.allSatisfy { !$0.isSelected })
            XCTAssertNil(state.categorySelected)
        }
    }
}
