//
//  Network.swift
//  RickAndMortyApp
//
//  Created by Álvaro Ortí on 11/5/24.
//

import Foundation
import Alamofire
import os.log

public class Network {
    var session: Session

    public init(session: Session = Session.default) {
        self.session = session
    }

    public func customRequest<T: Decodable>(endPoint: EndpointAssembly, type _: T.Type, timeout: TimeInterval = 10) async throws -> T {
        let headers = HTTPHeaders(endPoint.headers)
        var response: DataRequest
        do {
            switch endPoint.parameters {
                case .requestPlain:
                    response = session.request(
                        endPoint.urlString,
                        method: endPoint.method,
                        parameters: nil,
                        encoding: URLEncoding.default, // Assuming default encoding for requestPlain
                        headers: headers
                    )
                case let .requestParameters(parameters, encoding):
                    response = session.request(
                        endPoint.urlString,
                        method: endPoint.method,
                        parameters: parameters,
                        encoding: encoding,
                        headers: headers
                    )
            }
            
            let responseData = try await response.serializingDecodable(T.self).value
            Logger.log(model: .init(logType: .success, method: endPoint.method, responseCode: response.response?.statusCode, responseData: String(describing: responseData)))
            return responseData
        } catch {
            if let statusCode = response.response?.statusCode {
                let codeMessage = Network.handleResponse(statusCode: statusCode)
                Logger.log(model: .init(logType: .error, method: endPoint.method, responseCode: nil, responseData: codeMessage))
                throw NetworkError(responseCode: statusCode, errorDescription: codeMessage)
            } else {
                Logger.log(model: .init(logType: .error, method: endPoint.method, responseCode: nil, responseData: "invalid response"))
                throw NetworkError(responseCode: -999, errorDescription: "invalid response")
            }
        }
    }
    
    public static func handleResponse(statusCode: Int) -> String {
        var message = ""
        guard let httpStatusCode = HttpStatusCode(rawValue: statusCode) else {
            message = "Unknown status code: \(statusCode)"
            return message
        }
        
        if httpStatusCode.isSuccess {
            message = "Successful response"
        } else if (300..<400).contains(httpStatusCode.rawValue) {
            message = "Redirection"
        } else if (400..<500).contains(httpStatusCode.rawValue) {
            message = "Client error"
        } else if (500..<600).contains(httpStatusCode.rawValue) {
            message = "Server error"
        }
        return message
    }
}

// MARK: - Assembler
public struct EndpointAssembly {
    var headers: [String: String]
    var method: HTTPMethod
    var urlString: String
    var parameters: HTTPParameters
}


public enum HTTPParameters {
    case requestPlain
    case requestParameters(parameters: [String: Any], encoding: ParameterEncoding)
}

// MARK: - Error
public struct NetworkError: Error {
    public let responseCode: Int
    public let errorDescription: String
    
    public init(
        responseCode: Int,
        errorDescription: String
    ) {
        self.responseCode = responseCode
        self.errorDescription = errorDescription
    }
}
