//
//  CharacterSet+Utils.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 9/24/25.
//

import Foundation

extension CharacterSet {
    /// Characters allowed in a URI per RFC 3986.
    ///
    /// These are characters that are allowed in a URI but do not have a
    /// reserved purpose as per RFC 3986.
    ///
    /// - See: https://www.rfc-editor.org/rfc/rfc3986#section-2.3
    static let rfc3986Unreserved: CharacterSet = {
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-._~")
        return allowed
    }()
}

extension String {
    var rfc3986PercentEncoded: String {
        addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved) ?? ""
    }
}
