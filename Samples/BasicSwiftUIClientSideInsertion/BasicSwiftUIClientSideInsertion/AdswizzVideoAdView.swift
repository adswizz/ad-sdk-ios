//
//  AdswizzVideoAdView.swift
//  BasicSwiftUIClientSideInsertion
//
//  Created by Adrian Manolache on 10.11.2021.
//

import SwiftUI
import AdswizzSDK
import UIKit

struct AdswizzVideoAdView<Content>: UIViewRepresentable where Content: View {
    
    let videoView : AdVideoView
    let shouldOverrideUrl: Bool
    let fadeInAnimationDuration: Double
    let closeButtonUIKitView: UIView
    let container = UIView()
    
    init(videoView: AdVideoView,
         shouldOverrideUrl: Bool,
         fadeInAnimationDuration: Double,
         @ViewBuilder closeButton: () -> Content = { EmptyView() }) {
        
        self.videoView = videoView
        self.shouldOverrideUrl = shouldOverrideUrl
        self.fadeInAnimationDuration = fadeInAnimationDuration
        self.closeButtonUIKitView = UIHostingController(rootView: closeButton()).view
        self.closeButtonUIKitView.translatesAutoresizingMaskIntoConstraints = false
        self.closeButtonUIKitView.backgroundColor = .clear
    }

    func makeUIView(context: Context) -> UIView {
        videoView.delegate = context.coordinator
        videoView.alpha = 0.0
        container.alpha = 0.0
        
        videoView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(videoView)
        container.addSubview(closeButtonUIKitView)

        NSLayoutConstraint.activate([
            videoView.topAnchor.constraint(equalTo: container.topAnchor),
            videoView.leftAnchor.constraint(equalTo: container.leftAnchor),
            videoView.rightAnchor.constraint(equalTo: container.rightAnchor),
            videoView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            
            closeButtonUIKitView.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            closeButtonUIKitView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
        ])
        /// Don't forget to register the obstruction
        videoView.register(AdVideoFriendlyObstruction(view: closeButtonUIKitView, purpose: .closeAd))
        return container
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
        if fadeInAnimationDuration > 0, uiView.alpha == 0 {
            UIView.animate(withDuration: fadeInAnimationDuration, animations: {
                uiView.alpha = 1.0
                videoView.alpha = 1.0
            })
        }else {
            uiView.alpha = 1.0
            videoView.alpha = 1.0
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator : NSObject, AdVideoViewDelegate{
        let adswizzVideoAdView: AdswizzVideoAdView
        
        init(_ adswizzVideoAdView: AdswizzVideoAdView) {
            self.adswizzVideoAdView = adswizzVideoAdView
        }
        func adVideoView(_ adVideoView: AdVideoView, shouldOverrideVideoClickThrough url: URL) -> Bool {
           return adswizzVideoAdView.shouldOverrideUrl
        }
    }
}
