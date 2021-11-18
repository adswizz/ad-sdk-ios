//
//  AdswizzAdCompanionView.swift
//  BasicSwiftUIClientSideInsertion
//
//  Created by Adrian Manolache on 09.11.2021.
//

import SwiftUI
import AdswizzSDK

struct AdswizzAdCompanionView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> AdCompanionView {
        AdCompanionView()
    }

    func updateUIView(_ uiView: AdCompanionView, context: Context) {
    }
}
