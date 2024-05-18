//
//  AlamofireNetworkRequest.swift
//  RickAndMortyApp
//
//  Created by Alvaro Orti Moreno on 18/5/24.
//

import Foundation
import Alamofire

public class AlamofireNetworkRequest: NetworkRequest {
    private let session: Session

   public init(session: Session = .default) {
        self.session = session
    }

   public func request(
        _ convertible: URLConvertible,
        method: HTTPMethod,
        parameters: Parameters?,
        encoding: ParameterEncoding,
        headers: HTTPHeaders?
    ) async throws -> Data {
        return try await session.request(
            convertible,
            method: method,
            parameters: parameters,
            encoding: encoding,
            headers: headers
        ).serializingData().value
    }
}
