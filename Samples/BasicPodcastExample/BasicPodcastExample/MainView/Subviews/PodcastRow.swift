//
//  PodcastRow.swift
//  BasicPodcastExample
//
//  Created by George Mihoc on 19.01.2026.
//

import SwiftUI

struct PodcastRow: View {
    let podcast: PodcastItemState
    let isSelected: Bool
    let onSelect: (() -> Void)?
    let onDownload: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(podcast.title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 0) {
                detailsView
                actionButtonView
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: isSelected ? Color.black.opacity(0.4) : Color.black.opacity(0.1), radius: isSelected ? 8 : 4)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 5)
        .opacity(isSelected ? 1.0 : 0.8)
    }
    
    private var detailsView: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(podcast.filename)
                .font(.system(size: 14))
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            
            if podcast.isDownloading {
                Text("Downloading \(Int(podcast.downloadProgress * 100))%")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(15)
        .contentShape(Rectangle())
        .onTapGesture { onSelect?() }
    }
    
    private var actionButtonView: some View {
        Button(action: { onDownload?() }) {
            Text(podcast.isDownloaded ? "Remove" : "Download")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.5))
                .cornerRadius(8)
        }
        .disabled(!isSelected)
        .padding(.trailing, 10)
    }
}

#Preview {
    VStack {
        PodcastRow(podcast: PodcastItemState(id: 0,
                                             title: "Podcast 1",
                                             filename: "podcast_RAD_QueenBohemian.mp3",
                                             downloadProgress: 0.5,
                                             isDownloading: true,
                                             isDownloaded: false),
                   isSelected: true,
                   onSelect: nil,
                   onDownload: nil)
        PodcastRow(podcast: PodcastItemState(id: 1,
                                             title: "Podcast 2",
                                             filename: "podcast_RAD_muchosEvents.mp3",
                                             isDownloaded: true),
                   isSelected: false,
                   onSelect: nil,
                   onDownload: nil)
    }
    .padding()
}
