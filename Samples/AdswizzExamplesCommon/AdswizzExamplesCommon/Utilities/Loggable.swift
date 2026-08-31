//
//  Loggable.swift
//  AdswizzExamplesCommon
//
//  Created by George Mihoc on 25.06.2026.
//

import Foundation

/// Protocol for ViewModels that display a running log in the UI.
/// Conforming types only need to provide a `logs` stored property.
@MainActor public protocol Loggable: AnyObject {
    var logs: String { get set }
}

extension Loggable {
    public func addLog(_ line: String) {
        logs += line + "\n"
    }
}
