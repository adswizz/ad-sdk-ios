//
//  ServerSideExampleView.swift
//  BasicTVOSExample
//
//  Created by George Mihoc on 21.11.2024.
//

import AdswizzSDK
import SwiftUI

struct ServerSideExampleView: View {
    @StateObject var modelView = ServerSideModelView()
 
    var body: some View {
        controlsView
    }
    
    private var controlsView: some View {
        HStack(spacing: 50) {
            Button(action: modelView.isPlaying ? modelView.stop : modelView.start) {
                Text(!modelView.isPlaying ? "Start stream" : "Stop stream")
            }
            Button(action: modelView.skip) {
                Text("Skip ad")
            }
            .disabled(!modelView.isPlaying)
        }
    }
}

#Preview {
    ServerSideExampleView(modelView: ServerSideModelView())
}
