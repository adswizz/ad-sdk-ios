//
//  InAppNotificationAdExampleView.swift
//  BasicSwiftUIClientSideInsertion
//
//  Created by Adrian Manolache on 11.11.2021.
//

import SwiftUI

struct InAppNotificationAdExampleView: View {
    
    @StateObject var modelView = ModelView(adType: .banner, zoneIds: ["17862"])
 
    var body: some View {
        VStack {
            Text("Below the requested inapp notification ad(s)")
            
            AdswizzAdCompanionView()
                .frame(maxWidth: 400, maxHeight: 400)
                .background(Color.green.opacity(0.5))
                .cornerRadius(10)
            
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
