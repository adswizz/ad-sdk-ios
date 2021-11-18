//
//  ContentView.swift
//  BasicSwiftUIClientSideInsertion
//
//  Created by Adrian Manolache on 09.11.2021.
//

import SwiftUI
import AdswizzSDK

struct ContentView: View {
    var body: some View {
        TabView {
            BannerAdExampleView()
                .tabItem {
                    Label("Banner", systemImage: "photo")
                        .font(Font.system(size: 24))
                }
            
            VideoAdExampleView()
                .tabItem {
                    Label("Video", systemImage: "video.square")
                        .font(Font.system(size: 24))
                }
            
            InAppNotificationAdExampleView()
                .tabItem {
                    Label("InApp Notification", systemImage: "note.text")
                        .font(Font.system(size: 24))
                }
            
            TrackingPermissionsExampleView()
                .tabItem {
                    Label("Tracking Permissions", systemImage: "signature")
                        .font(Font.system(size: 24))
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
