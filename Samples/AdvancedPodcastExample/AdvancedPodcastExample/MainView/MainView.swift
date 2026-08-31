//
//  MainView.swift
//  AdvancedPodcastExample
//
//  Created by George Mihoc on 20.01.2026.
//

import SwiftUI
import AdswizzSDK

struct MainView: View {
    @ObservedObject var viewModel = MainViewModel()
    @State private var selectedPodcastForPlayer: PodcastConfig.Podcast?
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(viewModel.podcasts, id: \.id) { podcast in
                            PodcastRow(podcast: podcast,
                                       state: viewModel.playerState,
                                       isPlayingCurrent: viewModel.playingPodcast?.matches(podcast: podcast) ?? false)
                                .onTapGesture {
                                    viewModel.play(podcast: podcast)
                                    selectedPodcastForPlayer = podcast
                                    viewModel.showingPlayer = true
                                }
                            Divider()
                        }
                    }
                    .padding(.bottom, viewModel.minizimedPlayerVisible ? 170 : 0)
                }
                .navigationTitle("Podcasts")
                .navigationBarTitleDisplayMode(.large)
                
                if viewModel.minizimedPlayerVisible {
                    MinimizedPlayerView(title: viewModel.playingPodcast?.title ?? "",
                                        isPlaying: viewModel.playerState != .paused,
                                        onPlayPrevious: viewModel.playPrevious,
                                        onPlayNext: viewModel.playNext,
                                        onPlayPause: viewModel.togglePlayPause,
                                        onTap: {
                        selectedPodcastForPlayer = viewModel.playingPodcast
                        viewModel.showingPlayer = true
                    })
                    .transition(.move(edge: .bottom))
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $viewModel.showingPlayer) {
             if let selectedPodcastForPlayer {
                 PlayerView(podcast: selectedPodcastForPlayer, model: viewModel.model)
             } else if let playing = viewModel.playingPodcast {
                 PlayerView(podcast: playing, model: viewModel.model)
             }
        }
    }
}
