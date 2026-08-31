//
//  ServerSideModelView.swift
//  BasicTVOSExample
//
//  Created by George Mihoc on 04.12.2024.
//

import AVFoundation
import AdswizzSDK
import AdswizzExamplesCommon

final class ServerSideModelView: ServerSideAdViewModel {
    private let configStreamUrl = "https://streaming.sdk.eks.devel.adswizz.com/shakeDemo"

    override var streamUrl: URL? { URL(string: configStreamUrl) }

    override init() {
        super.init()
    }
    
    func start() {
        play()
    }

    func skip() {
        skipCurrentAd()
    }
}
