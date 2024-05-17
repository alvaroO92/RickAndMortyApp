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

    public static func log(model: LogModel) {
        let icon = Logger.icon(logType: model.logType)
        var logString = "[\(icon)] \(model.timestamp)"
        
        if let method = model.method, !method.rawValue.isEmpty {
            logString += " - Method: \(method.rawValue)"
        }
        
        if let responseCode = model.responseCode {
            logString += ", Response Code: \(responseCode)"
        }
        
        if let responseData = model.responseData, !responseData.isEmpty {
            logString += ", Response Data: \(responseData)"
        }
        
        if let description = model.description, !description.isEmpty {
            logString += ", Description: \(description)"
        }
        
        os_log("%{public}s", logString)
    }

}

extension Logger {
    
    public struct LogModel {
        var timestamp: String
        var logType: LogType
        var method: HTTPMethod?
        var responseCode: Int?
        var responseData: String?
        let description: String?
        
        init(
            logType: LogType,
            method: HTTPMethod? = nil,
            responseCode: Int? = nil,
            responseData: String? = nil,
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
        case error
        case warning
        case success
        case console
        
    }

    static func icon(logType: LogType) -> String {
        var icon = ""
        
        switch logType {
            case .error:
                icon = "📕"
            case .warning:
                icon = "📙"
            case .success:
                icon = "📗"
            case .console:
                icon = "📝"
        }
        
        return icon
    }
}
