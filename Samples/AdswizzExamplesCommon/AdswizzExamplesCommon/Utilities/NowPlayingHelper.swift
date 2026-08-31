//
//  NowPlayingHelper.swift
//  AdswizzExamplesCommon
//
//  Created by George Mihoc on 16.06.2026.
//

#if !os(tvOS)
import Foundation
import MediaPlayer

public enum NowPlayingHelper {

    public static func updateNowPlaying(
        with data: NowPlayableStaticMetadata,
        onPlay: @escaping @Sendable () -> Void,
        onPause: @escaping @Sendable () -> Void
    ) {
        MPNowPlayingInfoCenter.default().setNowPlayingMetadata(data)

        let remoteCenter = MPRemoteCommandCenter.shared()
        remoteCenter.playCommand.isEnabled = true
        remoteCenter.pauseCommand.isEnabled = true
        remoteCenter.playCommand.removeTarget(nil)
        remoteCenter.pauseCommand.removeTarget(nil)

        remoteCenter.playCommand.addTarget { _ in
            onPlay()
            return .success
        }

        remoteCenter.pauseCommand.addTarget { _ in
            onPause()
            return .success
        }
    }
}
#endif
