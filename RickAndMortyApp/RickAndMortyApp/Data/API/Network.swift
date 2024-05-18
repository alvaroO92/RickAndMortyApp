//
//  Network.swift
//  RickAndMortyApp
//
//  Created by Álvaro Ortí on 11/5/24.
//

import Foundation
import Alamofire
import os.log

public protocol NetworkRequest {
   func request(
      _ convertible: URLConvertible,
      method: HTTPMethod,
      parameters: Parameters?,
      encoding: ParameterEncoding,
      headers: HTTPHeaders?
   ) async throws -> Data
}

public class Network {
   var networkRequest: NetworkRequest
   
   public init(networkRequest: NetworkRequest = AlamofireNetworkRequest()) {
      self.networkRequest = networkRequest
   }
   
   public func customRequest<T: Codable>(endPoint: EndpointAssembly, type: T.Type, timeout: TimeInterval = 10) async throws -> T {
      let headers = HTTPHeaders(endPoint.headers)
      let data: Data
      
      switch endPoint.parameters {
         case .requestPlain:
            data = try await networkRequest.request(
               endPoint.urlString,
               method: endPoint.method,
               parameters: nil,
               encoding: URLEncoding.default,
               headers: headers
            )
         case let .requestParameters(parameters, encoding):
            data = try await networkRequest.request(
               endPoint.urlString,
               method: endPoint.method,
               parameters: parameters,
               encoding: encoding,
               headers: headers
            )
      }
      
      let model = Logger.LogModel(
         logType: .info,
         method: endPoint.method,
         responseCode: nil,
         responseData: data
      )
      
      Logger.log(model: model, responseType: T.self)
      
      let responseData = try JSONDecoder().decode(T.self, from: data)
      return responseData
   }
   
   public static func handleResponse(statusCode: Int) -> String {
      var message = ""
      guard let httpStatusCode = HttpStatusCode(rawValue: statusCode) else {
         message = "Unknown status code"
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
