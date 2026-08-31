//
//  ServerSideExampleView.swift
//  BasicTVOSExample
//
//  Created by George Mihoc on 21.11.2024.
//

import AdswizzSDK
import AdswizzExamplesCommon
import SwiftUI

struct ServerSideExampleView: View {
    @StateObject var modelView = ServerSideModelView()
 
    var body: some View {
        controlsView
    }
    
    private var controlsView: some View {
        HStack(spacing: 50) {
            Button {
                if modelView.isPlaying { modelView.stop() } else { modelView.start() }
            } label: {
                Text(!modelView.isPlaying ? "Start stream" : "Stop stream")
            }
            Button {
                modelView.skip()
            } label: {
                Text("Skip ad")
            }
            .disabled(!modelView.isPlaying)
        }
    }
}

#Preview {
    ServerSideExampleView(modelView: ServerSideModelView())
}
