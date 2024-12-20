//
//  HLSInterstitialExampleView.swift
//  AdvancedHLSInterstitialExample
//
//  Created by George Mihoc on 18.12.2024.
//

import AdswizzSDK
import SwiftUI

struct HLSInterstitialExampleView: View {
    @StateObject var modelView = HLSInterstitialModelView()
 
    var body: some View {
        VStack(spacing: 20) {
            adCompanionContainer
            LogsView(logs: modelView.logs)
            footerView
            Spacer()
        }
        .navigationTitle("HLS Interstitial")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var adCompanionContainer: some View {
        ZStack {
            if modelView.shouldDisplayAdCompanionView {
                AdCompanionSwiftUIView(delegate: modelView)
            } else {
                adCompanionViewPlaceholder
            }
        }
    }
    
    private var adCompanionViewPlaceholder: some View {
        ZStack {
            Color.gray.opacity(0.5)
            Text("AdCompanionView placeholder")
        }
    }
    
    private var footerView: some View {
        VStack(spacing: 10) {
            playheadView
            controlsView
        }
    }
    
    private var playheadView: some View {
        HStack {
            if let playhead = modelView.playhead {
                Text(String(playhead))
                    .font(.system(size: 13, weight: .bold))
            }
            Spacer()
            if let duration = modelView.duration {
                Text(String(duration))
                    .font(.system(size: 13, weight: .bold))
            }
        }
        .frame(height: 32)
        .padding(.horizontal, 10)
    }
    
    private var controlsView : some View {
        HStack(spacing: 50) {
            Button(action: modelView.isPlaying ? modelView.stop : modelView.start) {
                Text(!modelView.isPlaying ? "Start stream" : "Stop stream")
            }
            if modelView.isAdBreak {
                Button(action: modelView.isPausedAd ? modelView.resumeAd : modelView.pauseAd) {
                    Text(modelView.isPausedAd ? "Resume ad" : "Pause ad")
                }
                Button(action: modelView.skipAd) {
                    Text("Skip ad")
                }
            }
        }
    }
}

#Preview {
    HLSInterstitialExampleView(modelView: HLSInterstitialModelView())
}
