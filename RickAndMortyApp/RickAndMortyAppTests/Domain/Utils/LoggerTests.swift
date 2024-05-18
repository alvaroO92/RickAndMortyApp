//
//  LoggerTests.swift
//  RickAndMortyAppTests
//
//  Created by Alvaro Orti Moreno on 18/5/24.
//

import XCTest
import Foundation
@testable import RickAndMortyApp

class LoggerTests: XCTestCase {

    func testLogInfo() {
        let logModel = Logger.LogModel(logType: .info, description: "This is an informational message")
        let expectedLogString = "[ℹ️] \(logModel.timestamp)\nDescription: This is an informational message"
        
        var capturedLogString = ""
        let logger = Logger(logHandler: { logString in
            capturedLogString = logString
            XCTAssertEqual(capturedLogString, expectedLogString)
        })
        
        logger.log(model: logModel)
    }
    
    func testLogWarning() {
        let logModel = Logger.LogModel(logType: .warning, description: "This is a warning message")
        let expectedLogString = "[⚠️] \(logModel.timestamp)\nDescription: This is a warning message"
        
        var capturedLogString = ""
        let logger = Logger(logHandler: { logString in
            capturedLogString = logString
            XCTAssertEqual(capturedLogString, expectedLogString)
        })
        
        logger.log(model: logModel)
    }
    
    func testLogError() {
        let logModel = Logger.LogModel(logType: .error, description: "This is an error message")
        let expectedLogString = "[❌] \(logModel.timestamp)\nDescription: This is an error message"
        
        var capturedLogString = ""
        let logger = Logger(logHandler: { logString in
            capturedLogString = logString
            XCTAssertEqual(capturedLogString, expectedLogString)
        })
        
        logger.log(model: logModel)
    }
}
