//
//  MinimizedPlayerView.swift
//  AdvancedPodcastExample
//
//  Created by George Mihoc on 20.01.2026.
//

import SwiftUI

struct MinimizedPlayerView: View {
    let title: String
    let isPlaying: Bool
    let onPlayPrevious: () -> Void
    let onPlayNext: () -> Void
    let onPlayPause: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 20) {
                Image(systemName: "music.quarternote.3")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .foregroundColor(.blue)
                
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .lineLimit(1)
                    .foregroundColor(.black)
                Spacer()
                HStack(spacing: 20) {
                    Button(action: onPlayPrevious) {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 14))
                    }
                    
                    Button(action: onPlayPause) {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 24))
                    }
                    
                    Button(action: onPlayNext) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 14))
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(7)
            .shadow(color: Color.gray.opacity(0.5), radius: 5, x: 0, y: 0)
            .padding(.horizontal)
            .padding(.bottom, 24)
            .onTapGesture(perform: onTap)
        }
    }
}

#Preview {
    MinimizedPlayerView(title: "Title",
                        isPlaying: true,
                        onPlayPrevious: {},
                        onPlayNext: {},
                        onPlayPause: {},
                        onTap: {})
}
