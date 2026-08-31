//
//  MainView.swift
//  BasicAdStreamExample
//
//  Created by George Mihoc on 15.01.2026.
//  Copyright © 2026 Inc, AdsWizz. All rights reserved.
//

import AdswizzExamplesCommon
import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel = MainViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    StatusSection(version: viewModel.adswizzSDKVersion,
                                  status: viewModel.status,
                                  playedTime: nil)
                    
                    AdCompanionContainer(hasCompanionView: viewModel.hasCompanionView)
                    
                    ModelDescriptionSection(
                        title: "Stream Configuration",
                        adServer: viewModel.adServer,
                        streamUrl: viewModel.streamUrl?.absoluteString,
                        externalPlayerSwitchEnabled: viewModel.externalPlayerSwitchEnabled,
                        useExternalPlayer: $viewModel.useExternalPlayer
                    )
                    
                    ActionButtonsSection(isPlaying: viewModel.isPlaying,
                                         isPaused: viewModel.isPaused,
                                         showSkipAd: viewModel.showSkipAd,
                                         playStopAction: viewModel.didTapPlayStop,
                                         pauseResumeAction: viewModel.didTapPauseResume,
                                         skipAdAction: viewModel.didTapSkipAd)
                }
                .frame(minHeight: geometry.size.height)
            }
        }
        .cornerRadius(30)
        .padding(.vertical, 10)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Ad Streaming")
    }
}

#Preview {
    MainView()
}
