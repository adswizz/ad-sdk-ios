//
//  DVRViewModel.swift
//  BasicDVRRequestExample
//
//  Created by George Mihoc on 16.06.2026.
//

import AdswizzSDK
import AdswizzExamplesCommon

final class DVRViewModel: ServerSideAdViewModel {

    override var streamUrl: URL? {
        URL(string: "https://streaming.sdk.eks.devel.adswizz.com/shakeDemo")
    }

    override var streamCapabilities: [AdStreamCapability] { [.dvr] }

    override init() {
        super.init()
        externalPlayer = ExternalMediaPlayer()
    }
}
