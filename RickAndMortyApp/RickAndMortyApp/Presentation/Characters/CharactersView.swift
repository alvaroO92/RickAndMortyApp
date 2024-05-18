//
//  CharactersView.swift
//  RickAndMortyApp
//
//  Created by Álvaro Ortí on 11/5/24.
//

import SwiftUI

struct CharactersView: View {
    @StateObject var viewModel: CharactersViewModel

    @State private var searchText = ""
    @State private var isSheetPresented = false
    @State private var isResetEnabled = false

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                SearchBarView(text: $searchText)
                    .padding()
                
                switch viewModel.state {
                case .loading:
                    LoadingView()
                case .error:
                    ErrorView()
                case .loaded(let state):
                    if state.characters.isEmpty {
                        NoMatchingDataView {
                            viewModel.send(.refresh)
                        }
                    } else {
                        showCharactersView(for: state)
                    }
                }
                
                Spacer(minLength: 0)
            }
            .ignoresSafeArea(.all, edges: .bottom)
            .background(Color(hex: "#9fded5"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.send(.refresh)
                    }) {
                        Text("Reset")
                    }
                }
            }
        }
        .onAppear {
            Task {
                viewModel.send(.viewAppeared)
            }
        }
        .onChange(of: searchText) { _, newValue in
            viewModel.send(.search(newValue))
        }
        .sheet(isPresented: $isSheetPresented) {
            if let subCategories = viewModel.state.loadedState?.subCategories {
                SubCategoriesSheetView(categories: subCategories) { subcategoryTapped in
                    viewModel.send(.subCategoryTapped(subcategoryTapped))
                    isSheetPresented = false
                }
                .presentationDragIndicator(.visible)
                .presentationDetents([.fraction(0.3), .medium, .large])
            }
        }
        .onChange(of: viewModel.state) { _, newState in
           if let state = newState.loadedState, state.subCategories != nil {
              isSheetPresented = true
           } else {
              isSheetPresented = false
           }
        }
    }
    
    @ViewBuilder
    private func showCharactersView(for state: CharactersViewModel.State.LoadedState) -> some View {
        VStack(spacing: 8) {
            HorizontalFilterView(categories: state.categories) { category in
                viewModel.send(.categoryTapped(category.text))
            }
            CharactersScrollView(characters: state.characters) {
                viewModel.send(.loadMore)
            }
        }
    }
}

private struct LoadingView: View {
    var body: some View {
        ProgressView()
            .padding()
        Spacer()
    }
}

private struct ErrorView: View {
    var body: some View {
        Text("Error fetching characters")
            .foregroundColor(.red)
            .padding()
        Spacer()
    }
}

private struct NoMatchingDataView: View {
    var reloadAction: () -> Void
    
    var body: some View {
        VStack {
            Text("No matching data found")
                .foregroundColor(.gray)
                .padding()
            Button(action: {
                reloadAction()
            }) {
                Text("Reload")
            }
        }
    }
}

private struct HorizontalFilterView: View {
    let categories: [CharactersViewModel.CharacterViewModel]
    let onTap: (CharactersViewModel.CharacterViewModel) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(categories, id: \.self) { category in
                    CategoryItemView(category: category) {
                        onTap(category)
                    }
                }
            }
            .padding()
        }
    }
}

private struct CharactersScrollView: View {
    let characters: [Character]
    let onScrollEndReached: () -> Void
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 10) {
                ForEach(characters) { character in
                    CharacterRowView(character: character)
                        .onAppear {
                            if character == characters.last {
                                onScrollEndReached()
                            }
                        }
                }
            }
            .padding(10)
        }
    }
}
