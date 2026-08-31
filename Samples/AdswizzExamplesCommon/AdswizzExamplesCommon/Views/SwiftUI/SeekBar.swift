//
//  SeekBar.swift
//  AdswizzExamplesCommon
//
//  Created by George Mihoc on 09.06.2026.
//  Copyright © 2026 Adswizz. All rights reserved.
//

#if !os(tvOS)
import SwiftUI

public struct SeekBar: View {
    public let currentTime: TimeInterval
    public let totalDuration: TimeInterval
    public let onSeek: (Float) -> Void

    public init(currentTime: TimeInterval, totalDuration: TimeInterval, onSeek: @escaping (Float) -> Void) {
        self.currentTime = currentTime
        self.totalDuration = totalDuration
        self.onSeek = onSeek
    }

    public var body: some View {
        VStack(spacing: 5) {
            Slider(
                value: Binding(
                    get: { Float(currentTime) },
                    set: { onSeek($0) }
                ),
                in: 0...Float(max(totalDuration, 1))
            )
            .accentColor(.purple)

            HStack {
                Text(formatTime(currentTime))
                Spacer()
                Text(formatTime(totalDuration))
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
#endif
