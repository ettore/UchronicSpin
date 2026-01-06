//
//  FriendlyError.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 10/9/25.
//  Copyright © 2025 Ettore Pasquini. All rights reserved.
//

/// A protocol that all `Error` subclass should extend to support user and
/// developer friendly error messaging and logging.
///
/// - Important: different errors -- with different underlying causes and
/// developer friendly descriptions / errorIDs -- may have the same user
/// friendly description.
public protocol FriendlyError: Error, CustomStringConvertible {

    /// A localized description of the error that will be understandable by
    /// users of the app.
    var userFriendlyMessage: String {get}

    // MARK: Properties with default implementations

    /// A detailed description of the error in English.
    ///
    /// **Default implementation provided.**
    var devFriendlyDescription: String {get}
}


// MARK: - Default Implementations

public extension FriendlyError {
    /// Default implementation.
    ///
    /// This default implementation provides, in order:
    /// 1. The type of the error
    /// 2. String interpolation of `self` (doesn't seem to include the type,
    ///    but it does include interpolation of nested errors, if present)
    /// 3. The system `localizedDescription` of the error. This is sometimes
    /// redundant but it's provided as additional context.
    var devFriendlyDescription: String {
        "[\(type(of: self)): \(self)] \(localizedDescription)"
    }
}
