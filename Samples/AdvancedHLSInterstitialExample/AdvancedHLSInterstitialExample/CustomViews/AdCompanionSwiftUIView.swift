//
//  AdCompanionSwiftUIView.swift
//  AdvancedHLSInterstitialExample
//
//  Created by George Mihoc on 19.12.2024.
//

import AdswizzSDK
import SwiftUI

struct AdCompanionSwiftUIView: UIViewRepresentable {
    let delegate: AdCompanionViewDelegate?
    
    func makeUIView(context: Context) -> UIView {
        let adCompanionView = AdCompanionView()
        adCompanionView.delegate = delegate
        return adCompanionView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
