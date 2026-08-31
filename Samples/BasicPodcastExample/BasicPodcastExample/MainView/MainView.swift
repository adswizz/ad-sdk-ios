//
//  MainView.swift
//  BasicPodcastExample
//
//  Created by George Mihoc on 19.01.2026.
//

import AdswizzExamplesCommon
import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel = MainViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            AdCompanionContainer(hasCompanionView: viewModel.hasCompanionView)
            podcastsListView
            playbackControlsView
        }
    }
    
    private var podcastsListView: some View {
        ScrollView {
            VStack(spacing: 15) {
                ForEach(viewModel.podcasts, id: \.id) { podcast in
                    PodcastRow(
                        podcast: podcast,
                        isSelected: viewModel.selectedPodcastId == podcast.id,
                        onSelect: { viewModel.selectedPodcastId = podcast.id },
                        onDownload: { viewModel.downloadPressed(for: podcast.id) }
                    )
                }
            }
            .padding(.vertical, 10)
        }
    }
    
    private var playbackControlsView: some View {
        VStack(spacing: 15) {
            SeekBar(
                currentTime: viewModel.currentTime,
                totalDuration: viewModel.totalDuration,
                onSeek: { viewModel.seek(to: $0) }
            )
            
            Toggle("Use external player", isOn: $viewModel.useExternalPlayer)
                .padding(.horizontal, 40)
                .font(.system(size: 16))
            
            ActionButtonsSection(isPlaying: viewModel.isPlaying,
                                 isPaused: viewModel.isPaused,
                                 showSkipAd: viewModel.showSkipAd,
                                 playStopAction: viewModel.togglePlayStop,
                                 pauseResumeAction: viewModel.togglePauseResume,
                                 skipAdAction: viewModel.skipCurrentAd)
        }
    }
}

#Preview {
    MainView()
}
