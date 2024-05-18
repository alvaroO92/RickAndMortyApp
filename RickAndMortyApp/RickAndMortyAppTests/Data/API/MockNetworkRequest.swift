//
//  MockNetworkRequest.swift
//  RickAndMortyAppTests
//
//  Created by Alvaro Orti Moreno on 17/5/24.
//

import XCTest
import Alamofire
@testable import RickAndMortyApp

class MockNetworkRequest: NetworkRequest {
    var responseData: Data?
    var responseError: Error?

    func request(
        _ convertible: URLConvertible,
        method: HTTPMethod,
        parameters: Parameters?,
        encoding: ParameterEncoding,
        headers: HTTPHeaders?
    ) async throws -> Data {
        if let responseError = responseError {
            throw responseError
        }
        return responseData ?? Data()
    }
}
