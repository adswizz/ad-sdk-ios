//
//  BannerAdExampleView.swift
//  BasicSwiftUIClientSideInsertion
//
//  Created by Adrian Manolache on 11.11.2021.
//

import SwiftUI

fileprivate let animationDelay: Float = 0.4

/// You can use any sample in order  to integrate Adswizz AdCompanionView in a SwiftUI App depending on your use case.
/// Note: Those samples can be mixed and extended in your integration process.
/// The exposed methods includes various scenarious using AdCompanionView such as:
/// - add/remove in view hierarchy
/// - animations ( only in this scenario is needed animationDelay parameter)
/// - view composition
/// - AdCompanionViewDelegate interoperability with Coordinator class
struct BannerAdExampleView: View {
    @StateObject var modelView = ModelView(adType: .banner, zoneIds: ["17862"], companionZone: "17863")
    @State private var events: [String] = []
    
    var body: some View {
        VStack {
            
            HStack{
                Text("Below the requested banner ad(s)")
                
                Button{
                    events = []
                } label: {
                    Text("Clear Logs")
                }
            }
            
            CompanionContainer(
                backgroundBody: {
                    ZStack{
                        Color.red
                            .opacity(0.5)
                            .cornerRadius(10)
                           
                        Text("Companion placeholder with Frame &Uikit Animation")
                            .multilineTextAlignment(.center)
                    }
                },
                show: $modelView.hasCompanionView,
                animationDelay: animationDelay
            )
            .frame(maxWidth: .infinity, maxHeight: 400)

            
            ZStack{
                if modelView.hasCompanionView {
                    AdswizzAdCompanionView(
                        animationDelay: animationDelay,
                        onReceiveEvent: { event in
                            events.append(event)
                        },
                        shouldOverrideUrl: { url in
                            print("Url can be handled here")
                            return false
                        }
                    )

                    .frame(maxWidth: .infinity, maxHeight: 400)
                    .background(Color.blue.opacity(0.5))
                    .cornerRadius(10)
                }
                else {
                    ZStack{
                        Color.red
                            .opacity(0.5)
                            .frame(maxWidth: .infinity, maxHeight: 400)
                            .cornerRadius(10)
                        
                        Text("Companion placeholder with frame Animation")
                            .multilineTextAlignment(.center)
                    }
                    
                }
            }
            .animation(.easeInOut(duration: Double(animationDelay)), value: modelView.hasCompanionView)

            
            Button {
                if modelView.isPlaying {
                    modelView.stop()
                } else {
                    modelView.requestAds()
                }
            } label: {
                Text(!modelView.isPlaying ? "Request ad(s)" : "Stop")
            }
            
            ScrollView{
                
                LazyVStack(alignment: .center ,content: {
                    ForEach(events, id: \.self) { count in
                        Text(count)
                            .frame(maxWidth: .infinity)
                            .font(.system(size: 14))
                            .border(.black)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                        
                    }
                })
            }
        }
    }
}
