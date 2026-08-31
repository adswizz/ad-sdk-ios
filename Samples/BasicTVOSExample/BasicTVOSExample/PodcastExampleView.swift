//
//  PodcastExampleView.swift
//  BasicTVOSExample
//
//  Created by George Mihoc on 02.12.2024.
//

import AdswizzSDK
import AdswizzExamplesCommon
import SwiftUI

struct PodcastExampleView: View {
    @StateObject var modelView = PodcastModelView(podcastURL: "https://streaming.sdk.eks.devel.adswizz.com/podcast/podcast_RAD_QueenBohemian.mp3")
 
    var body: some View {
        controlsView
    }
    
    private var controlsView: some View {
        HStack(spacing: 50) {
            Button {
                if modelView.isPlaying { modelView.stop() } else { modelView.start() }
            } label: {
                Text(!modelView.isPlaying ? "Start podcast" : "Stop podcast")
            }
            Button {
                modelView.skip()
            } label: {
                Text("Skip ad")
            }
            .disabled(!modelView.isPlaying)
        }
    }
}

#Preview {
    PodcastExampleView(modelView: PodcastModelView(podcastURL: "https://streaming.sdk.eks.devel.adswizz.com/podcast/podcast_RAD_QueenBohemian.mp3"))
}
