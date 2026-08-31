//
//  AdRequestConfigModel.swift
//  AdswizzExamplesCommon
//
//  Created by George Mihoc on 16.06.2026.
//

import Foundation

public protocol AdRequestConfigModelProtocol {
    var modelName: String { get }
    var zoneId: String { get }
    var adServer: String { get }
    var companionZones: String { get }
    var description: String { get }
    var watchSupport: WatchSupport? { get }
}

public struct AdRequestConfigModel: AdRequestConfigModelProtocol {
    public var modelName: String
    public let zoneId: String
    public var adServer: String
    public var companionZones: String
    public var description: String
    public let watchSupport: WatchSupport?

    public init(_ zoneId: String, _ watchSupport: WatchSupport? = nil) {
        self.modelName = "Model name"
        self.zoneId = zoneId
        self.adServer = "demo.deliveryengine.adswizz.com"
        self.companionZones = "12562"
        self.description = "Model description"
        self.watchSupport = watchSupport
    }

    public init(
        _ modelName: String,
        _ zoneId: String,
        _ adServer: String,
        _ companionZones: String,
        _ description: String,
        _ watchSupport: WatchSupport? = nil
    ) {
        self.modelName = modelName
        self.zoneId = zoneId
        self.adServer = adServer
        self.companionZones = companionZones
        self.description = description
        self.watchSupport = watchSupport
    }
}
