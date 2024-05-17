//
//  CharactersDatasource.swift
//  RickAndMortyApp
//
//  Created by Álvaro Ortí on 11/5/24.
//

import Alamofire

struct CharactersDatasource {

    func getCharacters(page: Int) -> EndpointAssembly {
        EndpointAssembly(
            headers: [:],
            method: .get,
            urlString: ApiConstants.baseUrl + "character",
            parameters: .requestParameters(
                parameters: ["page": page],
                encoding: URLEncoding.queryString
            )
        )
    }

}
