//
//  Log.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 10/7/25.
//  Copyright © 2025 Ettore Pasquini. All rights reserved.
//

import os


protocol Logging {
    func debug(_ message: String)
    func debug(_ message: String, _ error: Error)
    func info(_: String)
    func info(_ message: String, _ error: Error)
    func warning(_: String)
    func warning(_ message: String, _ error: Error)
    func error(_: String)
    func error(_ message: String, _ error: Error)
    func fault(_: String)
    func fault(_ message: String, _ error: Error)
}

class Log: Logging {
    private let logger: Logger

    init(logger: Logger? = nil) {
        self.logger = logger ?? Logger()
    }

    // MARK: - API

    func debug(_ message: String) {
        logger.debug("\(message)")
    }

    func debug(_ message: String, _ err: Error) {
        if let err = err as? FriendlyError {
            logger.debug("\(message): \(err.devFriendlyDescription)")
        } else {
            logger.debug("\(message): \(err)")
        }
    }

    func info(_ message: String) {
        logger.info("\(message)")
    }

    func info(_ message: String, _ err: Error) {
        if let err = err as? FriendlyError {
            logger.info("\(message): \(err.devFriendlyDescription)")
        } else {
            logger.info("\(message): \(err)")
        }
    }

    func warning(_ message: String) {
        logger.warning("\(message)")
    }

    func warning(_ message: String, _ err: Error) {
        if let err = err as? FriendlyError {
            logger.warning("\(message): \(err.devFriendlyDescription)")
        } else {
            logger.warning("\(message): \(err)")
        }
    }

    func error(_ message: String) {
        logger.error("\(message)")
    }

    func error(_ message: String, _ err: Error) {
        if let err = err as? FriendlyError {
            logger.error("\(message): \(err.devFriendlyDescription)")
        } else {
            logger.error("\(message): \(err)")
        }
    }

    func fault(_ message: String) {
        logger.fault("\(message)")
    }

    func fault(_ message: String, _ err: Error) {
        if let err = err as? FriendlyError {
            logger.fault("\(message): \(err.devFriendlyDescription)")
        } else {
            logger.fault("\(message): \(err)")
        }
    }
}
