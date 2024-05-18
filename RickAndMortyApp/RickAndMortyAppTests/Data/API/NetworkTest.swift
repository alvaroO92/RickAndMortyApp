//
//  NetworkTest.swift
//  RickAndMortyAppTests
//
//  Created by Alvaro Orti Moreno on 17/5/24.
//

import XCTest
@testable import RickAndMortyApp

class NetworkTests: XCTestCase {

    var network: Network!
    var mockNetworkRequest: MockNetworkRequest!

    override func setUp() {
        super.setUp()
        mockNetworkRequest = MockNetworkRequest()
        network = Network(networkRequest: mockNetworkRequest)
    }

    override func tearDown() {
        network = nil
        mockNetworkRequest = nil
        super.tearDown()
    }

   func testCustomRequestSuccess() async throws {
      let expectedData = """
              {
                  "id": 1,
                  "name": "Rick Sanchez",
                  "status": "Alive",
                  "species": "Human",
                  "gender": "Male",
                  "image": "https://example.com/image.png"
              }
              """.data(using: .utf8)
      
      mockNetworkRequest.responseData = expectedData
      
      
      let endpoint = EndpointAssembly(
         headers: [:],
         method: .get,
         urlString: "https://example.com",
         parameters: .requestPlain
      )
      let character = try await network.customRequest(endPoint: endpoint, type: CharacterDto.self)
      
      XCTAssertEqual(character.name, "Rick Sanchez")
      XCTAssertEqual(character.status, "Alive")
      XCTAssertEqual(character.species, "Human")
      XCTAssertEqual(character.gender, "Male")
      XCTAssertEqual(character.image, "https://example.com/image.png")
   }

    func testCustomRequestFailure() async throws {
        mockNetworkRequest.responseError = NetworkError(responseCode: 404, errorDescription: "Not Found")

        let endpoint = EndpointAssembly(
            headers: [:],
            method: .get,
            urlString: "https://example.com",
            parameters: .requestPlain
        )
        do {
            let _: CharacterDto = try await network.customRequest(endPoint: endpoint, type: CharacterDto.self)
            XCTFail("Expected to throw, but succeeded")
        } catch let error as NetworkError {
            XCTAssertEqual(error.responseCode, 404)
            XCTAssertEqual(error.errorDescription, "Not Found")
        }
    }

    func testHandleResponse() {
        XCTAssertEqual(Network.handleResponse(statusCode: 200), "Successful response")
        XCTAssertEqual(Network.handleResponse(statusCode: 400), "Client error")
        XCTAssertEqual(Network.handleResponse(statusCode: 500), "Server error")
        XCTAssertEqual(Network.handleResponse(statusCode: 999), "Unknown status code")
    }
}

