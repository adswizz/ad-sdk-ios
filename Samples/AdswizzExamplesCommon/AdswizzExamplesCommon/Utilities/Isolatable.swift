//
//  Isolatable.swift
//  AdswizzExamplesCommon
//
//  Created by George Mihoc on 14.07.2026.
//

import Foundation

public protocol Isolatable: AnyObject {
    func onMainActor(_ work: @MainActor @escaping () -> Void)
}

public extension Isolatable {
    func onMainActor(_ work: @MainActor @escaping () -> Void) {
        if Thread.isMainThread {
            MainActor.assumeIsolated(work)
        } else {
            Task { @MainActor in
                work()
            }
        }
    }
}
