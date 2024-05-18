//
//  Logger.swift
//  RickAndMortyApp
//
//  Created by Álvaro Ortí on 11/5/24.
//

import Foundation
import os.log
import Alamofire

public struct Logger {

   public static func log(model: LogModel, responseType: Codable.Type? = nil) {
         let icon = Logger.icon(logType: model.logType)
         var logComponents: [String] = ["[\(icon)] \(model.timestamp)"]
         
         if let method = model.method, !method.rawValue.isEmpty {
             logComponents.append("Method: \(method.rawValue)")
         }
         
         if let responseCode = model.responseCode {
             logComponents.append("Response Code: \(responseCode)")
         }
         
         if let responseData = model.responseData, !responseData.isEmpty, let responseType {
             do {
                let decoder = JSONDecoder()
                let decodedResponse = try decoder.decode(responseType, from: responseData)
                let jsonString = JSONEncoder().logEncodedAndPrettyPrinted(decodedResponse)
                logComponents.append("Response Data: \(jsonString)")
             } catch {
                 logComponents.append("Response Data: (Failed to decode JSON: \(error))")
             }
         }
         
         if let description = model.description, !description.isEmpty {
             logComponents.append("Description: \(description)")
         }
         
         let logString = logComponents.joined(separator: "\n")
         os_log("%{public}s", logString)
     }
}

extension Logger {
    
    public struct LogModel {
        var timestamp: String
        var logType: LogType
        var method: HTTPMethod?
        var responseCode: Int?
        var responseData: Data?
        let description: String?
        
        init(
            logType: LogType,
            method: HTTPMethod? = nil,
            responseCode: Int? = nil,
            responseData: Data? = nil,
            description: String? = nil
        ) {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
            let timestamp = formatter.string(from: Date())
            
            self.timestamp = timestamp
            self.logType = logType
            self.method = method
            self.responseCode = responseCode
            self.responseData = responseData
            self.description = description
        }
    }
    
    enum LogType {
       case info, warning, error
    }

   static func icon(logType: LogType) -> String {
      switch logType {
         case .info: return "ℹ️"
         case .warning: return "⚠️"
         case .error: return "❌"
      }
   }
}
