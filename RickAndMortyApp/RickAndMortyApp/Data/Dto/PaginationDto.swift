//
//  PaginationDto.swift
//  RickAndMortyApp
//
//  Created by Álvaro Ortí on 11/5/24.
//

import Foundation

struct PaginationDto: Decodable {
    let pages: Int
    let count: Int
    let next: String?
    
    var hasNext: Bool {
        !(next?.isEmpty == true)
    }
}
