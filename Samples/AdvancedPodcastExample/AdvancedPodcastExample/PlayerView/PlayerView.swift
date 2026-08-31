//
//  PlayerView.swift
//  AdvancedPodcastExample
//
//  Created by George Mihoc on 20.01.2026.
//

import SwiftUI
import AdswizzSDK
import AdswizzExamplesCommon

struct PlayerView: View {
    @StateObject var viewModel: PlayerViewModel
    @SwiftUI.Environment(\.presentationMode) var presentationMode
    
    init(podcast: PodcastConfig.Podcast?, model: AppModel) {
        _viewModel = StateObject(wrappedValue: PlayerViewModel(podcast: podcast, model: model))
    }
    
    var body: some View {
        VStack {
            dismissView
            Spacer()
            ZStack {
                if viewModel.showCompanion {
                    AdswizzAdCompanionView()
                } else {
                    Image(systemName: "music.quarternote.3")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.blue)
                        .padding(40)
                }
            }
            .frame(maxHeight: 350)
            
            detailsView
            
            Spacer()
            
            VStack(spacing: 30) {
                controlsView
                
                SeekBar(
                    currentTime: viewModel.playhead,
                    totalDuration: viewModel.duration,
                    onSeek: { viewModel.seek(to: $0) }
                )
            }
            .padding(.bottom, 40)
        }
    }
    
    private var dismissView: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
    }
    
    private var detailsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.podcast?.title ?? "")
                .font(.title3)
                .fontWeight(.regular)
            Text(viewModel.podcast?.author ?? "")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var controlsView: some View {
        HStack(spacing: 40) {
            Button(action: viewModel.seekBackward) {
                Image(systemName: "gobackward.10")
                    .font(.largeTitle)
            }
            
            Button(action: viewModel.play) {
                Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 50))
            }
            
            Button(action: viewModel.seekForward) {
                Image(systemName: "goforward.10")
                    .font(.largeTitle)
            }
        }
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
