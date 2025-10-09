//
//  MockLog.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 10/9/25.
//  Copyright © 2025 Ettore Pasquini. All rights reserved.
//

@testable import Uchronic_Spin

class MockLog: Logging {
    func debug(_ message: String) {
        print("DEBUG: \(message)")
    }
    
    func debug(_ message: String, _ error: any Error) {
        print("DEBUG: \(message): \(String(describing: error))")
    }
    
    func info(_ message: String) {
        print("INFO: \(message)")
    }
    
    func info(_ message: String, _ error: any Error) {
        print("INFO: \(message): \(String(describing: error))")
    }
    
    func warning(_ message: String) {
        print("WARNING: \(message)")
    }
    
    func warning(_ message: String, _ error: any Error) {
        print("WARNING: \(message): \(String(describing: error))")
    }
    
    func error(_ message: String) {
        print("ERROR: \(message)")
    }
    
    func error(_ message: String, _ error: any Error) {
        print("ERROR: \(message): \(String(describing: error))")
    }
    
    func fault(_ message: String) {
        print("FAULT: \(message)")
    }
    
    func fault(_ message: String, _ error: any Error) {
        print("FAULT: \(message): \(String(describing: error))")
    }
}
