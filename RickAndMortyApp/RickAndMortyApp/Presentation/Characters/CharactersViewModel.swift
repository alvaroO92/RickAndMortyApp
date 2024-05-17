//
//  CharactersViewModel.swift
//  RickAndMortyApp
//
//  Created by Álvaro Ortí on 11/5/24.
//

import Foundation

@MainActor
final class CharactersViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published private(set) var state: State = .loading
    
    // MARK: - Private Properties
    private var currentPage = 1
    private var allCharacters: [Character] = []
    private var filteredCharacters: [Character] = []
    private var isFetchingData = false
    private var currentCategory: Category?
    private var currentSubCategory: CharacterViewModel?
    
    private let charactersUseCase: CharactersUseCase
    
    // MARK: - Initialization
    init(charactersUseCase: CharactersUseCase = .live) {
        self.charactersUseCase = charactersUseCase
    }
    
    // MARK: - Public Methods
    func send(_ event: Event) {
        Task {
            await handleEvent(event)
        }
    }

    private func handleEvent(_ event: Event) async {
        do {
            switch event {
            case .viewAppeared, .refresh:
                try await fetchDataIfNeeded(resetPagination: true, resetData: true) // Refresh or initial load, reset both pagination and data
            case .loadMore:
                try await fetchDataIfNeeded(resetPagination: false, resetData: false) // Load more data, don't reset anything
            case .search(let value):
                updateState(.loading)
                let filteredCharacters = search(text: value) // Filter characters based on search text
                updateState(.loaded(.init(characters: filteredCharacters, categories: state.loadedState?.categories ?? [], categorySelected: state.loadedState?.categorySelected)))
            case .categoryTapped(let categoryName):
                await categoryTapped(categoryName)
            case .subCategoryTapped(let category):
                await updateStateAfterSubCategoryTapped(category: category)
            case .toggleCategorySelection(let categoryName):
                guard let loadedState = state.loadedState,
                      let index = loadedState.categories.firstIndex(where: { $0.text == categoryName }) else {
                    return
                }
                var updatedCategories = loadedState.categories
                updatedCategories[index].isSelected.toggle()
                updateState(.loaded(.init(characters: loadedState.characters, categories: updatedCategories, categorySelected: loadedState.categorySelected)))
            }
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - Private Methods
    private func fetchDataIfNeeded(resetPagination: Bool, resetData: Bool) async throws {
        guard !isFetchingData else { return }
        isFetchingData = true
        
        if resetPagination {
            currentPage = 1
            filteredCharacters = [] // Reset filtered characters if resetting pagination
        }
        
        if resetData {
            allCharacters = [] // Reset all characters if needed
            filteredCharacters = []
            currentSubCategory = nil // Ensure no subcategory selected
        }

        let response = try await charactersUseCase.getCharacters(currentPage)
        if resetPagination {
            allCharacters = response.characters
        } else {
            allCharacters.append(contentsOf: response.characters)
        }
        
        if let subCategory = currentSubCategory {
            filteredCharacters = filterCharacters(bySubCategory: subCategory, in: allCharacters)
        } else {
            filteredCharacters = allCharacters
        }
        
        updateStateWithAllCharacters() // Update state with filtered or all characters
        
        currentPage += 1
        isFetchingData = false
    }

    
    private func updateStateWithAllCharacters() {
        updateState(.loaded(.init(characters: filteredCharacters, categories: Category.allCases.map { CharacterViewModel(text: $0.rawValue, colorString: $0.color) }, categorySelected: currentCategory)))
    }
    
    private func search(text: String) -> [Character] {
        guard !text.isEmpty else {
            return allCharacters
        }

        return allCharacters.filter { character in
            guard let name = character.name else { return false }
            let searchTextLowercased = text.lowercased()
            let nameLowercased = name.lowercased()
            return nameLowercased.contains(searchTextLowercased)
        }
    }
    
    private func updateState(_ newState: State) {
        DispatchQueue.main.async {
            self.state = newState
        }
    }

    private func handleError(_ error: Error) {
        Logger.log(model: .init(logType: .error, responseData: error.localizedDescription))
        updateState(.error(error.localizedDescription))
    }
    
    private func categoryTapped(_ categoryName: String) async {
        guard let category = Category(rawValue: categoryName) else { return }
        currentCategory = category
        let subCategories = await getSubCategories(for: category)
        if !subCategories.isEmpty, let state = state.loadedState {
            updateState(.loaded(state.newState(subCategories: subCategories)))
        }
    }
    
    private func updateStateAfterSubCategoryTapped(category: CharacterViewModel) async {
        currentSubCategory = category
        try? await fetchDataIfNeeded(resetPagination: false, resetData: false)
    }

    private func getSubCategories(for category: Category) async -> [CharacterViewModel] {
        switch category {
        case .status:
            return Character.Status.allCases.map { CharacterViewModel(text: $0.rawValue, colorString: $0.color, parent: category) }
        case .species:
            return Character.Species.allCases.map { CharacterViewModel(text: $0.rawValue, colorString: $0.color, parent: category) }
        case .gender:
            return Character.Gender.allCases.map { CharacterViewModel(text: $0.rawValue, colorString: $0.color, parent: category) }
        }
    }
    
    private func filterCharacters(bySubCategory subCategory: CharacterViewModel, in characters: [Character]) -> [Character] {
        let subcategoryText = subCategory.text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        let filteredCharacters: [Character]
        
        switch subCategory.parent {
        case .status:
            filteredCharacters = characters.filter { character in
                guard let characterStatus = character.status?.rawValue else { return false }
                let statusLowercased = subcategoryText.lowercased()
                let characterStatusLowercased = characterStatus.lowercased()
                return characterStatusLowercased.starts(with: statusLowercased)
            }
        case .species:
            filteredCharacters = characters.filter { character in
                guard let characterSpecies = character.species?.rawValue else { return false }
                let speciesLowercased = subcategoryText.lowercased()
                let characterSpeciesLowercased = characterSpecies.lowercased()
                return characterSpeciesLowercased.starts(with: speciesLowercased)
            }
        case .gender:
            filteredCharacters = characters.filter { character in
                guard let characterGender = character.gender?.rawValue else { return false }
                let genderLowercased = subcategoryText.lowercased()
                let characterGenderLowercased = characterGender.lowercased()
                return characterGenderLowercased.starts(with: genderLowercased)
            }
        default:
            filteredCharacters = characters
        }
        
        return filteredCharacters
    }
}

extension CharactersViewModel {
    
    enum Event {
        case viewAppeared
        case refresh
        case loadMore
        case search(String)
        case categoryTapped(String)
        case subCategoryTapped(CharacterViewModel)
        case toggleCategorySelection(String)
    }
}


extension CharactersViewModel {
    
    enum State: Equatable {
        case loading
        case loaded(LoadedState)
        case error(String)
        
        var loadedState: LoadedState? {
            if case let .loaded(loadedState) = self {
                return loadedState
            }
            return nil
        }
        
        struct LoadedState: Equatable {
            let characters: [Character]
            let categories: [CharacterViewModel]
            let categorySelected: Category?
            var subCategories: [CharacterViewModel]?
            
            func newState(characters: [Character]? = nil, subCategories: [CharacterViewModel]? = nil) -> LoadedState {
                return LoadedState(
                    characters: characters ?? self.characters,
                    categories: self.categories,
                    categorySelected: self.categorySelected,
                    subCategories: subCategories ?? self.subCategories
                )
            }
        }
    }
    
    struct CharacterViewModel: Equatable, Identifiable, Hashable {
        var id: String
        let text: String
        let colorString: String
        let parent: Category?
        var isSelected: Bool
        
        init(text: String, colorString: String, parent: Category? = nil, isSelected: Bool = false) {
            self.id = UUID().uuidString
            self.text = text
            self.colorString = colorString
            self.parent = parent
            self.isSelected = isSelected
        }
    }
}

extension CharactersViewModel {

    enum Category: String, CaseIterable {
        case gender = "Gender"
        case species = "Species"
        case status = "Status"
        
        var color: String {
            switch self {
            case .gender:
                return "#02afc5"
            case .species:
                return "#35c9dd"
            case .status:
                return "#a6cccc"
            }
        }
    }
}
