//
//  AdswizzVideoAdView.swift
//  BasicTVOSExample
//
//  Created by George Mihoc on 18.11.2024.
//

import AdswizzSDK
import SwiftUI
import UIKit

struct AdswizzVideoAdView: UIViewRepresentable {
    let videoView: AdVideoView
    let shouldOverrideUrl: Bool
    let fadeInAnimationDuration: Double
    
    init(videoView: AdVideoView,
         shouldOverrideUrl: Bool,
         fadeInAnimationDuration: Double) {
        self.videoView = videoView
        self.shouldOverrideUrl = shouldOverrideUrl
        self.fadeInAnimationDuration = fadeInAnimationDuration
    }

    func makeUIView(context: Context) -> UIView {
        videoView.delegate = context.coordinator
        videoView.alpha = 0.0
        return videoView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if fadeInAnimationDuration > 0, uiView.alpha == 0 {
            UIView.animate(withDuration: fadeInAnimationDuration, animations: {
                uiView.alpha = 1.0
                videoView.alpha = 1.0
            })
        } else {
            uiView.alpha = 1.0
            videoView.alpha = 1.0
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, AdVideoViewDelegate {
        let adswizzVideoAdView: AdswizzVideoAdView
        
        init(_ adswizzVideoAdView: AdswizzVideoAdView) {
            self.adswizzVideoAdView = adswizzVideoAdView
        }
        
        func adVideoView(_ adVideoView: AdVideoView, shouldOverrideVideoClickThrough url: URL) -> Bool {
            adswizzVideoAdView.shouldOverrideUrl
        }
    }
}
