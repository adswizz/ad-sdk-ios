//
//  AdswizzAdCompanionView.swift
//  BasicTVOSExample
//
//  Created by George Mihoc on 06.03.2025.
//

import SwiftUI
import AdswizzSDK

struct AdswizzAdCompanionView: UIViewRepresentable {
    
    private let onReceiveEvent : (String) -> ()
    private let shouldOverrideUrl : (String) -> Bool
    private let animationDelay: Float
    private let uiView : AdCompanionView = AdCompanionView()
    
    init(
        // not required if not using animation modifiers
        animationDelay: Float = -1,
        // callbacks to forward events received through AdCompanionViewDelegate
        onReceiveEvent: @escaping (String) -> () = { _ in },
        shouldOverrideUrl: @escaping (String) -> Bool = { _ in false }
    ){
        self.onReceiveEvent = onReceiveEvent
        self.shouldOverrideUrl = shouldOverrideUrl
        self.animationDelay = animationDelay
    }
    
    func makeUIView(context: Context) -> AdCompanionView {
        uiView.delegate = context.coordinator
        return uiView
    }
    
    func updateUIView(_ uiView: AdCompanionView, context: Context) {
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
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator : NSObject, AdCompanionViewDelegate {
        
        let view: AdswizzAdCompanionView
        init(_ view: AdswizzAdCompanionView) {
            self.view = view
        }
        
        func adCompanionViewWillLoad(_ adCompanionView: AdCompanionView) {
            view.onReceiveEvent("WillLoadAd for \(adCompanionView)")
        }
        
        func adCompanionViewDidDisplay(_ adCompanionView: AdCompanionView) {
            view.onReceiveEvent("DidDisplayAd for \(adCompanionView)")
        }
        
        func adCompanionViewDidEndDisplay(_ adCompanionView: AdCompanionView) {
            view.onReceiveEvent("DidEndDisplay for \(adCompanionView)")
        }
        func adCompanionViewWillLeaveApplication(_ adCompanionView: AdCompanionView) {
            view.onReceiveEvent("WillLeaveApplication for \(adCompanionView)")
        }
        
        func adCompanionView(_ adCompanionView: AdCompanionView, didFailToDisplay error: any Error) {
            view.onReceiveEvent("DidFailToDisplay with \(error.localizedDescription) for \(adCompanionView)")
        }
        func adCompanionView(_ adCompanionView: AdCompanionView, shouldOverrideCompanionClickThrough url: URL) -> Bool {
            view.onReceiveEvent("ShouldOverrideUrl \(url.absoluteString) for \(adCompanionView)")
            return view.shouldOverrideUrl(url.absoluteString)
        }
        
    }
}


struct SwiftUIAnimatedCompanion: UIViewRepresentable {
    
    private let companionView = AdCompanionView()
    @Binding var shouldForceRedraw: Bool
    let animationDelay: Float
    
    func makeUIView(context: Context) -> AdCompanionView {
        companionView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        if shouldForceRedraw {
            Task {
                // wait for the SwiftUI animation to settle, then animate the AdCompanionView content
                if animationDelay >= 0 {
                    let delay = UInt64((animationDelay + 0.1) * 1_000_000_000)
                    try await Task.sleep(nanoseconds: delay)                }
                uiView.alpha = 0
                UIView.animate(withDuration: 0.5, animations: {
                    uiView.alpha = 1
                })
            }
        }
    }
    
}

/// This is another container sample using SwiftUI onAppear modifier to redraw AdCompanionView content after using animation modifiers
struct CompanionContainer<BackgroundBody>: View  where BackgroundBody : View {
    
    @ViewBuilder var backgroundBody: () -> BackgroundBody
    @Binding var show: Bool
    let animationDelay: Float
    
    @State private var shouldRefresh : Bool = false
    
    var body: some View {
        
        ZStack{
            if show{
                SwiftUIAnimatedCompanion(shouldForceRedraw: $shouldRefresh, animationDelay: animationDelay)
                    .background(Color.blue.opacity(0.5))
                    .onAppear(perform: {
                        shouldRefresh = true
                    })
            } else {
                backgroundBody()
                    .onAppear(perform: {
                        shouldRefresh = false
                    })
            }
            
        }.animation(.easeInOut, value: show)
        
    }
}
