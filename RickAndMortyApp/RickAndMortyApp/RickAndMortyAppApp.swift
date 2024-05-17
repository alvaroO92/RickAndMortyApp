//
//  RickAndMortyAppApp.swift
//  RickAndMortyApp
//
//  Created by Alvaro Orti Moreno on 17/5/24.
//

import SwiftUI

@main
struct RickAndMortyAppApp: App {
   var body: some Scene {
      WindowGroup {
         SplashScreenView {
            CharactersView(viewModel: CharactersViewModel(charactersUseCase: .live))
         } splashScreenImage: {
            Image("SplashScreen")
               .resizable()
         }
      }
   }
}
