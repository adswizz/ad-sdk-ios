//
//  AdswizzVideoAdView.swift
//  BasicSwiftUIClientSideInsertion
//
//  Created by Adrian Manolache on 10.11.2021.
//

import SwiftUI
import AdswizzSDK

struct AdswizzVideoAdView: UIViewRepresentable {
    @ObservedObject var modelView: ModelView
    let videoView = AdVideoView()
    
    func makeUIView(context: Context) -> AdVideoView {
        modelView.videoView = videoView
        return videoView
    }
    
    func updateUIView(_ uiView: AdVideoView, context: Context) {
    }
}
