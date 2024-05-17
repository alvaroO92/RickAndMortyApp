//
//  Character.swift
//  RickAndMortyApp
//
//  Created by Álvaro Ortí on 11/5/24.
//

import Foundation

struct Character: Identifiable, Equatable {
    let id: Int
    let name: String?
    let status: Status?
    let species: Species?
    let gender: Gender?
    let image: String?
    
    static func == (lhs: Character, rhs: Character) -> Bool {
        lhs.id == rhs.id
    }
    
}

extension Character {
   
   public static func from(charactersDto: CharacterDto) -> Self {
      Character(
          id: charactersDto.id,
          name: charactersDto.name,
          status: charactersDto.status.flatMap { Character.Status(rawValue: $0) },
          species: charactersDto.species.flatMap { Character.Species(rawValue: $0) },
          gender: charactersDto.gender.flatMap { Character.Gender(rawValue: $0) },
          image: charactersDto.image
      )
   }

}

extension Character {
    
    public static let mock = Character(
        id: UUID().hashValue,
        name: "name",
        status: .alive,
        species: .animal,
        gender: .female,
        image: ""
    )
    
}

extension Character {
    
    enum Category: String {
        case gender = "Gender"
        case species = "Species"
        case status = "Status"
    }

    // MARK: - Status
    enum Status: String, CaseIterable {
        case alive = "Alive"
        case dead = "Dead"
        case unknown = "unknown"
        
        var color: String {
            return "#a6cccc"
        }
    }

    // MARK: - Species
    enum Species: String, CaseIterable {
        case alien = "Alien"
        case animal = "Animal"
        case cronenberg = "Cronenberg"
        case disease = "Disease"
        case human = "Human"
        case humanoid = "Humanoid"
        case mythologicalCreature = "Mythological Creature"
        case poopybutthole = "Poopybutthole"
        case robot = "Robot"
        case unknown = "unknown"
        
        var color: String {
            return "#35c9dd"
        }
    }

    // MARK: - Gender
    enum Gender: String, CaseIterable {
        case female = "Female"
        case genderless = "Genderless"
        case male = "Male"
        case unknown = "unknown"
        
        var color: String {
            return "#02afc5"
        }
    }

}
