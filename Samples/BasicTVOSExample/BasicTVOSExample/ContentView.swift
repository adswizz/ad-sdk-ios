//
//  ContentView.swift
//  BasicTVOSExample
//
//  Created by George Mihoc on 18.11.2024.
//

import SwiftUI
import AdswizzSDK

struct ContentView: View {
    var body: some View {
        TabView {
            ClientSideExampleView()
                .tabItem {
                    Label("Client Side", systemImage: "iphone")
                        .font(Font.system(size: 24))
                }
            ServerSideExampleView()
                .tabItem {
                    Label("Server Side", systemImage: "server.rack")
                        .font(Font.system(size: 24))
                }
            PodcastExampleView()
                .tabItem {
                    Label("Podcast", systemImage: "microphone.square")
                        .font(Font.system(size: 24))
                }
        }
    }
}

#Preview {
    ContentView()
}
