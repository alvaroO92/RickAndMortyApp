//
//  HttpStatusCode.swift
//  RickAndMortyApp
//
//  Created by Álvaro Ortí on 11/5/24.
//

import Foundation

enum HttpStatusCode: Int {
    case success = 200
    case redirection = 300
    case clientError = 400
    case serverError = 500
    
    var isSuccess: Bool {
        return (200..<300).contains(rawValue)
    }
}
