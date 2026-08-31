//
//  AdswizzAdCompanionView.swift
//  AdswizzExamplesCommon
//
//  Created by George Mihoc on 09.06.2026.
//  Copyright © 2026 Adswizz. All rights reserved.
//

import AdswizzSDK
import SwiftUI

public struct AdswizzAdCompanionView: UIViewRepresentable {
    
    private let onReceiveEvent: (String) -> Void
    private let shouldOverrideUrl: (String) -> Bool
    private let animationDelay: Float
    private let uiView: AdCompanionView = AdCompanionView()
    
    public init(
        // not required if not using animation modifiers
        animationDelay: Float = -1,
        // callbacks to forward events received through AdCompanionViewDelegate
        onReceiveEvent: @escaping (String) -> Void = { _ in },
        shouldOverrideUrl: @escaping (String) -> Bool = { _ in false }
    ) {
        self.onReceiveEvent = onReceiveEvent
        self.shouldOverrideUrl = shouldOverrideUrl
        self.animationDelay = animationDelay
    }
    
    public func makeUIView(context: Context) -> AdCompanionView {
        uiView.delegate = context.coordinator
        return uiView
    }
    
    public func updateUIView(_ uiView: AdCompanionView, context: Context) {
        // we can schedule a redraw if a layout animation is present
        if animationDelay > 0 {
            Task {
                let delay = UInt64((animationDelay + 0.1) * 1_000_000_000)
                try await Task.sleep(nanoseconds: delay)
                uiView.alpha = 0
                uiView.alpha = 1.0
            }
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    @MainActor public class Coordinator: NSObject, AdCompanionViewDelegate {
        let view: AdswizzAdCompanionView

        init(_ view: AdswizzAdCompanionView) {
            self.view = view
        }
        
        public func adCompanionViewWillLoad(_ adCompanionView: AdCompanionView) {
            view.onReceiveEvent("WillLoadAd for \(adCompanionView)")
        }
        
        public func adCompanionViewDidDisplay(_ adCompanionView: AdCompanionView) {
            view.onReceiveEvent("DidDisplayAd for \(adCompanionView)")
        }
        
        public func adCompanionViewDidEndDisplay(_ adCompanionView: AdCompanionView) {
            view.onReceiveEvent("DidEndDisplay for \(adCompanionView)")
        }

        public func adCompanionViewWillLeaveApplication(_ adCompanionView: AdCompanionView) {
            view.onReceiveEvent("WillLeaveApplication for \(adCompanionView)")
        }
        
        public func adCompanionView(_ adCompanionView: AdCompanionView, didFailToDisplay error: any Error) {
            view.onReceiveEvent("DidFailToDisplay with \(error.localizedDescription) for \(adCompanionView)")
        }

        public func adCompanionView(_ adCompanionView: AdCompanionView, shouldOverrideCompanionClickThrough url: URL) -> Bool {
            view.onReceiveEvent("ShouldOverrideUrl \(url.absoluteString) for \(adCompanionView)")
            return view.shouldOverrideUrl(url.absoluteString)
        }
    }
}
