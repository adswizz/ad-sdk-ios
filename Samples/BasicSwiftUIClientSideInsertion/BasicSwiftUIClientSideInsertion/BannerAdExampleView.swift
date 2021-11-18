//
//  BannerAdExampleView.swift
//  BasicSwiftUIClientSideInsertion
//
//  Created by Adrian Manolache on 11.11.2021.
//

import SwiftUI

struct BannerAdExampleView: View {
    @StateObject var modelView = ModelView(adType: .banner, zoneIds: ["12561"], companionZone: "12562")
 
    var body: some View {
        VStack {
            Text("Below the requested banner ad(s)")
            
            AdswizzAdCompanionView()
                .frame(maxWidth: 400, maxHeight: 400)
                .background(Color.blue)
                .cornerRadius(100)
            
            Button {
                if modelView.isPlaying {
                    modelView.stop()
                } else {
                    modelView.requestAds()
                }
            } label: {
                Text(!modelView.isPlaying ? "Request ad(s)" : "Stop")
            }
        }
    }
}

