//
//  PodcastRow.swift
//  AdvancedPodcastExample
//
//  Created by George Mihoc on 20.01.2026.
//

import SwiftUI
import AdswizzSDK

struct PodcastRow: View {
    let podcast: PodcastConfig.Podcast
    let state: Playlist.State
    let isPlayingCurrent: Bool
    
    var body: some View {
        HStack {
            iconView
            detailsView
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
    
    private var iconView: some View {
        Image(systemName: "music.note.list")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 30, height: 30)
            .padding(.trailing, 10)
            .foregroundColor(isPlayingCurrent ? .blue : .black)
    }
    
    private var detailsView: some View {
        VStack(alignment: .leading) {
            Text(podcast.title)
                .font(.headline)
            Text(podcast.author)
                .font(.subheadline)
                .fontWeight(.bold)
        }
    }
}
