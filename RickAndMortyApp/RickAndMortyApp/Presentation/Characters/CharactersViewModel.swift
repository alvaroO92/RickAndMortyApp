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
    
    /// Handles various events and updates the state accordingly.
    func send(_ event: Event) {
        Task {
            await handleEvent(event)
        }
    }

    // MARK: - Private Methods
    
    /// Handles the events and performs corresponding actions.
    private func handleEvent(_ event: Event) async {
        do {
            switch event {
            case .viewAppeared, .refresh:
                await refreshData()
            case .loadMore:
                try await fetchDataIfNeeded(resetPagination: false, resetData: false)
            case .search(let value):
                updateState(.loading)
                let filteredCharacters = search(text: value)
                updateState(.loaded(.init(characters: filteredCharacters, categories: state.loadedState?.categories ?? [], categorySelected: state.loadedState?.categorySelected)))
            case .categoryTapped(let categoryName):
                await categoryTapped(categoryName)
            case .subCategoryTapped(let category):
                await updateStateAfterSubCategoryTapped(category: category)
            case .toggleCategorySelection(let categoryName):
                toggleCategorySelection(categoryName: categoryName)
            }
        } catch {
            handleError(error)
        }
    }
    
    /// Refreshes the data by resetting the state and fetching data.
    private func refreshData() async {
        resetState()
        do {
            try await fetchDataIfNeeded(resetPagination: true, resetData: true)
        } catch {
            handleError(error)
        }
    }

    /// Resets the state to its initial values.
    private func resetState() {
        currentPage = 1
        allCharacters = []
        filteredCharacters = []
        currentCategory = nil
        currentSubCategory = nil
        resetCategorySelection()
    }

    /// Fetches data if needed and updates the state accordingly.
    private func fetchDataIfNeeded(resetPagination: Bool, resetData: Bool) async throws {
        guard !isFetchingData else { return }
        isFetchingData = true
        
        defer { isFetchingData = false }
        
        if resetPagination {
            currentPage = 1
            filteredCharacters = []
        }
        
        if resetData {
            allCharacters = []
            filteredCharacters = []
            currentSubCategory = nil
        }

        let response = try await charactersUseCase.getCharacters(currentPage)
        allCharacters.append(contentsOf: response.characters)
        
        if let subCategory = currentSubCategory {
            filteredCharacters = filterCharacters(bySubCategory: subCategory, in: allCharacters)
        } else {
            filteredCharacters = allCharacters
        }
        
        updateStateWithAllCharacters()
        
        currentPage += 1
    }

    /// Resets the selection of all categories.
    private func resetCategorySelection() {
        guard let loadedState = state.loadedState else { return }
        let updatedCategories = loadedState.categories.map { category in
            var updatedCategory = category
            updatedCategory.isSelected = false
            return updatedCategory
        }
        updateState(.loaded(loadedState.newState(categories: updatedCategories, categorySelected: nil)))
    }

    /// Updates the state with all characters.
    private func updateStateWithAllCharacters() {
        guard let loadedState = state.loadedState else {
            updateState(.loaded(.init(characters: filteredCharacters, categories: Category.allCases.map { CharacterViewModel(text: $0.rawValue, colorString: $0.color) }, categorySelected: nil)))
            return
        }
        updateState(.loaded(.init(characters: filteredCharacters, categories: loadedState.categories, categorySelected: currentCategory)))
    }

    /// Searches for characters based on the provided text.
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

    /// Updates the state ensuring it is called on the main thread.
    private func updateState(_ newState: State) {
        DispatchQueue.main.async {
            self.state = newState
        }
    }

    /// Handles errors by logging them and updating the state.
    private func handleError(_ error: Error) {
        Logger().log(model: .init(logType: .error, description: error.localizedDescription))
        updateState(.error(error.localizedDescription))
    }

    /// Handles the tapping of a category.
    private func categoryTapped(_ categoryName: String) async {
        guard let category = Category(rawValue: categoryName) else { return }
        currentCategory = category
        let subCategories = await getSubCategories(for: category)
        if !subCategories.isEmpty, let state = state.loadedState {
            updateState(.loaded(state.newState(subCategories: subCategories)))
        }
    }
    
    /// Updates the state after a subcategory is tapped.
    private func updateStateAfterSubCategoryTapped(category: CharacterViewModel) async {
        currentSubCategory = category
        markCategoryAsSelected(category.parent)
        try? await fetchDataIfNeeded(resetPagination: false, resetData: false)
    }

    /// Gets subcategories for a given category.
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

    /// Marks a category as selected.
    private func markCategoryAsSelected(_ category: Category?) {
        guard let category = category, let loadedState = state.loadedState else { return }
        let updatedCategories = loadedState.categories.map { cat in
            var updatedCategory = cat
            if updatedCategory.text == category.rawValue {
                updatedCategory.isSelected = true
            } else {
                updatedCategory.isSelected = false
            }
            return updatedCategory
        }
        updateState(.loaded(loadedState.newState(categories: updatedCategories, categorySelected: category)))
    }
    
    /// Toggles the selection of a category.
    private func toggleCategorySelection(categoryName: String) {
        guard let loadedState = state.loadedState,
              let index = loadedState.categories.firstIndex(where: { $0.text == categoryName }) else {
            return
        }
        var updatedCategories = loadedState.categories
        updatedCategories[index].isSelected.toggle()
        updateState(.loaded(.init(characters: loadedState.characters, categories: updatedCategories, categorySelected: updatedCategories[index].isSelected ? Category(rawValue: categoryName) : nil)))
    }
    
    /// Filters characters by subcategory.
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
            
            func newState(characters: [Character]? = nil, categories: [CharacterViewModel]? = nil, subCategories: [CharacterViewModel]? = nil, categorySelected: Category? = nil) -> LoadedState {
                return LoadedState(
                    characters: characters ?? self.characters,
                    categories: categories ?? self.categories,
                    categorySelected: categorySelected ?? self.categorySelected,
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
