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
    
    typealias LogHandler = (String) -> Void
    
    var logHandler: LogHandler?
    
   init(logHandler: LogHandler? = nil) {
        self.logHandler = logHandler
    }
    
    func log(model: LogModel) {
        let logString = generateLogString(from: model)
        os_log("%{public}s", logString)
        logHandler?(logString)
    }
    
    func generateLogString(from model: LogModel) -> String {
        var logComponents: [String] = ["[\(icon(logType: model.logType))] \(model.timestamp)"]
        
        if let method = model.method, !method.rawValue.isEmpty {
            logComponents.append("Method: \(method.rawValue)")
        }
        
        if let responseCode = model.responseCode {
            logComponents.append("Response Code: \(responseCode)")
        }
        
        if let responseData = model.responseData, !responseData.isEmpty {
            do {
                let jsonString = try logEncodedAndPrettyPrinted(responseData)
                logComponents.append("Response Data: \(jsonString)")
            } catch {
                logComponents.append("Response Data: (Failed to decode JSON: \(error))")
            }
        }
        
        if let description = model.description, !description.isEmpty {
            logComponents.append("Description: \(description)")
        }
        
        return logComponents.joined(separator: "\n")
    }
    
    private func icon(logType: LogType) -> String {
        switch logType {
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        }
    }
    
    private func logEncodedAndPrettyPrinted(_ data: Data) throws -> String {
        let prettyPrintedJSON = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
        let prettyData = try JSONSerialization.data(withJSONObject: prettyPrintedJSON, options: .prettyPrinted)
        guard let prettyString = String(data: prettyData, encoding: .utf8) else {
            throw NSError(domain: "Failed to pretty print JSON", code: 0, userInfo: nil)
        }
        return prettyString
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
