//
//  RequesterProtocol.swift
//  AdswizzSDKPrivacyDataCore
//
//  Created by Teodor Cristea on 22.05.2024.
//  Copyright © 2024 AdsWizz, inc. All rights reserved.
//

import Foundation

/// An Objective-C `NSObject` wrapper around the Swift `Result<Success, Failure>` to maintain Obj-C interoperability.
@objc public class RequestResult: NSObject {
    
    /// The success argument. See the `PermissionValue` enum for possible values.
    @objc public private(set) var success: PermissionValue
    
    /// The failure argument. A generic `Error`.
    @objc public private(set) var failure: Error?
    
    /// Initialize the `RequestResult` object.
    /// Note that for a valid result, the `RequestResult` object should be initialized with only one non-optional argument. Otherwise, an `unknownResult` error will be returned.
    ///
    /// - parameter success: The success argument as `PermissionValue`.
    /// - parameter failure: The failure argument as `Error`.
    public init(success: PermissionValue, failure: Error? = nil) {
        self.success = success
        self.failure = failure
    }
}

/// `RequestResult` extension.
public extension RequestResult {
    /// Convenience API to obtain a Swift `Result<Success, Failure>` based on an Objective-C `RequestResult`.
    var result: Result<PermissionValue, Error> {
        if let error = failure {
            return .failure(error)
        }
        return .success(success)
    }
}

/// A closure that is passed to the `request(completion:)` method to register for a callback with the result of the permission request.
/// The completion block will always occur on the main thread.
///
/// - parameter result: The output of the `request(completion:)` method when it completes.
public typealias RequestCompletion = (_ result: RequestResult) -> Void

/// The interface for all the requesters implementations.
@objc public protocol RequesterProtocol: AnyObject {
    
    /// The current authorization status.
    @objc
    var authorizationStatus: PermissionValue { get }
    
    /// Request the permission handled by a requester implementation.
    ///
    /// - parameter completion: The completion block.
    @objc(request:)
    func request(completion: @escaping RequestCompletion)
}
