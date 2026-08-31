//
//  MainView.swift
//  BasicVideoAdExample
//
//  Created by George Mihoc on 18.01.2026.
//

import AdswizzExamplesCommon
import SwiftUI

struct MainView: View {
    @StateObject var viewModel = MainViewModel()
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                statusSection
                Spacer()
                if viewModel.showVideoView {
                    minimizedVideoView
                }
                Spacer()
                actionButtonsSection
            }
            if viewModel.isFullscreen, viewModel.showVideoView {
                fullscreenVideoView
            }
        }
    }
    
    private var statusSection: some View {
        Text(viewModel.adswizzSDKVersion)
            .font(.headline)
            .padding(.top, 20)
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 15) {
            Toggle("Use External Player", isOn: $viewModel.useExternalPlayer)
                .disabled(!viewModel.externalPlayerSwitchEnabled)
                .padding(.horizontal, 40)
            
            VStack(alignment: .trailing, spacing: 5) {
                Text(viewModel.adCountText)
                    .fontWeight(.bold)
                Text(viewModel.totalAdsDurationText)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.horizontal, 20)
            
            Button(action: viewModel.didTapActionButton) {
                Text(viewModel.isPlayingAds ? "Stop ads" : "Request ads")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(Color(red: 0.5, green: 0.5, blue: 1.0))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 30)
        }
    }
    
    private var minimizedVideoView: some View {
        SwiftUIVideoView(
            videoView: viewModel.adVideoView,
            skipState: $viewModel.skipState,
            isFullscreen: $viewModel.isFullscreen,
            isLoading: $viewModel.isLoading,
            showSkipButton: $viewModel.showSkipButton,
            onSkipTapped: viewModel.didTapSkipAd,
            onDoubleTap: viewModel.didDoubleTapVideo
        )
        .frame(width: viewModel.isFullscreen ? UIScreen.main.bounds.width : UIScreen.main.bounds.width * 0.85,
               height: viewModel.isFullscreen ? UIScreen.main.bounds.height : UIScreen.main.bounds.height / 2.8)
        .transition(.move(edge: .trailing).combined(with: .opacity))
    }
    
    private var fullscreenVideoView: some View {
        SwiftUIVideoView(
            videoView: viewModel.adVideoView,
            skipState: $viewModel.skipState,
            isFullscreen: $viewModel.isFullscreen,
            isLoading: $viewModel.isLoading,
            showSkipButton: $viewModel.showSkipButton,
            onSkipTapped: viewModel.didTapSkipAd,
            onDoubleTap: viewModel.didDoubleTapVideo
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
        .zIndex(100)
    }
}

#Preview {
    MainView()
}
