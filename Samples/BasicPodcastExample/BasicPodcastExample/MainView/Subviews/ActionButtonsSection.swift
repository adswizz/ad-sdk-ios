//
//  ActionButtonsSection.swift
//  BasicPodcastExample
//
//  Created by George Mihoc on 19.01.2026.
//

import AdswizzExamplesCommon
import SwiftUI

struct ActionButtonsSection: View {
    let isPlaying: Bool
    let isPaused: Bool
    let showSkipAd: Bool
    
    var playStopAction: (() -> Void)?
    var pauseResumeAction: (() -> Void)?
    var skipAdAction: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 30) {
                ActionButtonView(title: isPlaying ? "Stop podcast" : "Play podcast",
                                 action: playStopAction)
                
                ActionButtonView(title: isPaused ? "Resume podcast" : "Pause podcast",
                                 action: pauseResumeAction)
            }
            
            ActionButtonView(title: "Skip ad(s)", action: skipAdAction)
                .padding(.horizontal, 40)
                .opacity(showSkipAd ? 1 : 0.6)
                .disabled(!showSkipAd)
        }
        .padding()
    }
}
