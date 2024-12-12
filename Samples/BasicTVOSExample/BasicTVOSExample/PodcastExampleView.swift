//
//  PodcastExampleView.swift
//  BasicTVOSExample
//
//  Created by George Mihoc on 02.12.2024.
//

import AdswizzSDK
import SwiftUI

struct PodcastExampleView: View {
    @StateObject var modelView = PodcastModelView(podcastURL: "http://sdk.mobile.streaming.adswizz.com:8501/podcast_RAD_QueenBohemian.mp3")
 
    var body: some View {
        controlsView
    }
    
    private var controlsView: some View {
        HStack(spacing: 50) {
            Button(action: modelView.isPlaying ? modelView.stop : modelView.start) {
                Text(!modelView.isPlaying ? "Start podcast" : "Stop podcast")
            }
            Button(action: modelView.skip) {
                Text("Skip ad")
            }
            .disabled(!modelView.isPlaying)
        }
    }
}

#Preview {
    PodcastExampleView(modelView: PodcastModelView(podcastURL: "http://sdk.mobile.streaming.adswizz.com:8501/podcast_RAD_QueenBohemian.mp3"))
}
