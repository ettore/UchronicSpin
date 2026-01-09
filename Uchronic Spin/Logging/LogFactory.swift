//
//  LogFactory.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 1/11/26.
//  Copyright © 2026 Ettore Pasquini. All rights reserved.
//

import Foundation
import os


enum LogFactory {
    static func makeSettingsLog() -> Logging {
        make(for: "Settings")
    }

    static func makeAuthLog() -> Logging {
        make(for: "Auth")
    }

    static func makeAPILog() -> Logging {
        make(for: "API")
    }

    static func make(for category: String) -> Logging {
        let subsystem = Bundle.main.bundleIdentifier ?? "Uchronic-Spin"
        return Log(logger: Logger(subsystem: subsystem, category: category))
    }
}

