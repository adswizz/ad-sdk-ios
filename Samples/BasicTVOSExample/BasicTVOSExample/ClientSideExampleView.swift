//
//  ClientSideExampleView.swift
//  BasicTVOSExample
//
//  Created by George Mihoc on 18.11.2024.
//

import AdswizzSDK
import SwiftUI

struct ClientSideExampleView: View {
    @StateObject var modelView = ClientSideModelView(zoneIds:  ["17161", "12561"])
 
    var body: some View {
        VStack(spacing: 50.0) {
            contentView
            controlsView
        }
    }
    
    private var contentView: some View {
        ZStack {
            if modelView.isPlaying,
               let adVideoView = modelView.videoView,
               case .video = modelView.adType {
                videoView(for: adVideoView)
            } else {
                videoViewPlaceholder
            }
        }
        .animation(.easeInOut(duration: 0.5), value: modelView.isPlaying)
    }
    
    private var videoViewPlaceholder: some View {
        ZStack {
            Color.red
                .opacity(0.5)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            Text("Video View placeholder")
        }
    }
    
    private func videoView(for adVideoView: AdVideoView) -> some View {
        ZStack {
            AdswizzVideoAdView(
                videoView: adVideoView,
                shouldOverrideUrl: false,
                fadeInAnimationDuration: 1.0
            )
        }
        .background(Color.blue.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private var controlsView: some View {
        HStack(spacing: 50) {
            Button(action: modelView.isPlaying ? modelView.stop : modelView.requestAds) {
                Text(!modelView.isPlaying ? "Request ad(s)" : "Stop")
            }
            Button(action: modelView.skip) {
                Text("Skip ad")
            }
            .disabled(!modelView.isPlaying)
        }
    }
}

#Preview {
    ClientSideExampleView(modelView: ClientSideModelView(zoneIds: ["17161"]))
}
