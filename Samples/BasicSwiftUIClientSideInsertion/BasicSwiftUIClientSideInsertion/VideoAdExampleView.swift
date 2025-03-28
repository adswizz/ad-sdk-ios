//
//  VideoAdExampleView.swift
//  BasicSwiftUIClientSideInsertion
//
//  Created by Adrian Manolache on 11.11.2021.
//

import SwiftUI

fileprivate let animationDelay = 0.5

struct VideoAdExampleView: View {
    @StateObject var modelView = ModelView(adType: .video, zoneIds:  ["19984"])
 
    var body: some View {
        VStack {
            Text("Below the requested video ad(s)")
            
            ZStack{
                if modelView.isPlaying {
                    if let videoView = modelView.videoView{
                        AdswizzVideoAdView(
                            videoView: videoView,
                            shouldOverrideUrl: false,
                            fadeInAnimationDuration: 1.0,
                            closeButton: {
                                Button(action: {
                                    modelView.skip()
                                }, label: {
                                    Text("Skip Ad").foregroundColor(Color.blue)
                                })
                                .padding(.horizontal)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(10)
                            }
                        )
                        .frame(maxWidth: .infinity, maxHeight: 400)
                        .background(Color.blue.opacity(0.5))
                        .cornerRadius(10)
                    }
                    else {
                        EmptyView()
                    }
                }
                else {
                    ZStack {
                        Color.red
                            .opacity(0.5)
                            .frame(maxWidth: .infinity, maxHeight: 400)
                            .cornerRadius(10)
                    
                        Text("Video View placeholder")
                    }
                }
            }
            .animation(.easeInOut(duration: animationDelay),value: modelView.isPlaying)
           
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
