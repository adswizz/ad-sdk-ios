//
//  VideoAdExampleView.swift
//  BasicSwiftUIClientSideInsertion
//
//  Created by Adrian Manolache on 11.11.2021.
//

import SwiftUI

struct VideoAdExampleView: View {
    @StateObject var modelView = ModelView(adType: .video, zoneIds:  ["17161"])
 
    var body: some View {
        VStack {
            Text("Below the requested video ad(s)")
            VStack {
                AdswizzVideoAdView(modelView: modelView)
            }.frame(maxWidth: 400, maxHeight: 400)
                .background(Color.red.opacity(0.5))
                .cornerRadius(10)
            Button {
                if modelView.isPlaying {
                    modelView.stop()
                } else {
                    modelView.requestAds()
                }
            } label: {
                Text(!modelView.isPlaying ? "Request ad(s)" : "Stop")
            }
        }
    }
}
