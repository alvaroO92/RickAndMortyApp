//
//  JsonEncoder.swift
//  RickAndMortyApp
//
//  Created by Alvaro Orti Moreno on 18/5/24.
//

import Foundation

extension JSONEncoder {
    func encodeAndPrettyPrint<T: Encodable>(_ value: T) throws -> String {
        let jsonData = try self.encode(value)
        let prettyPrintedJSON = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if let prettyData = try? JSONSerialization.data(withJSONObject: prettyPrintedJSON, options: .prettyPrinted),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            return prettyString
        } else {
            return "(Failed to pretty print JSON)"
        }
    }
    
    func logEncodedAndPrettyPrinted<T: Encodable>(_ value: T) -> String {
        do {
            let jsonString = try self.encodeAndPrettyPrint(value)
            return "Response Data:\n\(jsonString)"
        } catch {
            return "Response Data: (Failed to pretty print JSON)"
        }
    }
}
