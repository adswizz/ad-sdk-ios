//
//  AdswizzAdVideoView.swift
//  AdswizzExamplesCommon
//
//  Created by George Mihoc on 09.06.2026.
//

import AdswizzSDK
import SwiftUI

public struct AdswizzAdVideoView: UIViewRepresentable {
    public let videoView: AdVideoView
    public var shouldOverrideUrl: Bool
    public var fadeInAnimationDuration: Double
    @Binding public var isFullscreen: Bool

    public init(
        videoView: AdVideoView,
        shouldOverrideUrl: Bool = false,
        fadeInAnimationDuration: Double = 0,
        isFullscreen: Binding<Bool> = .constant(false)
    ) {
        self.videoView = videoView
        self.shouldOverrideUrl = shouldOverrideUrl
        self.fadeInAnimationDuration = fadeInAnimationDuration
        self._isFullscreen = isFullscreen
    }

    public func makeUIView(context: Context) -> AdVideoView {
        // Only set the delegate if it hasn't been set externally (e.g. by the ViewModel).
        if videoView.delegate == nil {
            videoView.delegate = context.coordinator
        }
        if fadeInAnimationDuration > 0 {
            videoView.alpha = 0.0
        }
        return videoView
    }

    public func updateUIView(_ uiView: AdVideoView, context: Context) {
        // Update fullscreen state
        let targetState: AdVideoState = isFullscreen ? .fullscreen : .normal
        if uiView.state != targetState {
            uiView.state = targetState
        }

        // Fade-in animation
        if fadeInAnimationDuration > 0, uiView.alpha == 0 {
            UIView.animate(withDuration: fadeInAnimationDuration) {
                uiView.alpha = 1.0
            }
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, AdVideoViewDelegate {
        let parent: AdswizzAdVideoView

        init(_ parent: AdswizzAdVideoView) {
            self.parent = parent
        }

        public func adVideoView(_ adVideoView: AdVideoView, shouldOverrideVideoClickThrough url: URL) -> Bool {
            return parent.shouldOverrideUrl
        }
    }
}
