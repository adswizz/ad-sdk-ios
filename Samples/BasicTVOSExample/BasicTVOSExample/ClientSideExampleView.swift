//
//  ClientSideExampleView.swift
//  BasicTVOSExample
//
//  Created by George Mihoc on 18.11.2024.
//

import AdswizzSDK
import AdswizzExamplesCommon
import SwiftUI

struct ClientSideExampleView: View {
    @StateObject var modelView = ClientSideModelView(zoneIds:  ["17862", "17161"], companionZone: "17863")
 
    var body: some View {
        VStack(spacing: 50.0) {
            contentView
            controlsView
        }
        .padding(.top, 50.0)
    }
    
    private var contentView: some View {
        ZStack {
            switch modelView.adType {
            case .video:
                if modelView.isPlaying, let adVideoView = modelView.videoView {
                    videoView(for: adVideoView)
                } else {
                    contentViewPlaceholder
                }
            default:
                if modelView.hasCompanionView, !modelView.refreshCompanionGrid {
                    ZStack {
                        adCompanionGrid
                        contentViewPlaceholder
                            .opacity(modelView.isPlaying ? 0 : 1)
                        adCompanionGridControlsContainerView
                            .opacity(modelView.isPlaying ? 1 : 0)
                    }
                } else {
                    contentViewPlaceholder
                        .opacity(modelView.refreshCompanionGrid ? 0 : 1)
                }
            }
        }
        .animation(.easeInOut(duration: 0.5), value: modelView.isPlaying)
    }
    
    private var contentViewPlaceholder: some View {
        ZStack {
            Color.blue
                .clipShape(RoundedRectangle(cornerRadius: 10))
            Text("Content View placeholder")
        }
    }
    
    private func videoView(for adVideoView: AdVideoView) -> some View {
        AdswizzAdVideoView(
            videoView: adVideoView,
            shouldOverrideUrl: false,
            fadeInAnimationDuration: 1.0
        )
        .background(Color.blue.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private var adCompanionGrid: some View {
        VStack {
            horizontalAdCompanionRow(for: 0)
            if modelView.companionGrid == .quad {
                horizontalAdCompanionRow(for: 1)
            }
        }
    }
    
    private func horizontalAdCompanionRow(for index: Int) -> some View {
        HStack {
            ZStack {
                adCompanionView
                if modelView.shouldHideCompanionView(for: index * 2) {
                    adCompanionObstructionView
                }
            }
            if modelView.companionGrid == .double || modelView.companionGrid == .quad {
                ZStack {
                    adCompanionView
                    if modelView.shouldHideCompanionView(for: (index * 2) + 1) {
                        adCompanionObstructionView
                    }
                }
            }
        }
    }
    
    private var adCompanionGridControlsContainerView: some View {
        VStack {
            Spacer()
            adCompanionGridControlsView
        }
        .padding(10)
    }
    
    private var adCompanionGridControlsView: some View {
        HStack(spacing: 50) {
            Button {
                modelView.increaseAdCompanionGrid()
            } label: {
                Text("+")
            }
            .disabled(modelView.companionGrid == .quad)
            Button {
                modelView.decreaseAdCompanionGrid()
            } label: {
                Text("-")
            }
            .disabled(modelView.companionGrid == .single)
        }
        .disabled(!modelView.isPlaying)
    }
    
    private var adCompanionView: some View {
        AdswizzAdCompanionView(animationDelay: .zero)
            .frame(maxWidth: .infinity)
            .background(Color.blue.opacity(0.5))
            .cornerRadius(10)
    }
    
    private var adCompanionObstructionView: some View {
        Rectangle()
            .frame(maxWidth: .infinity)
            .foregroundStyle(Color.gray)
            .cornerRadius(10)
    }
    
    private var controlsView: some View {
        VStack(spacing: 50) {
            companionControlsView
            mediaControlsView
        }
    }
    
    private var companionControlsView: some View {
        HStack(spacing: 50) {
            ForEach(0..<modelView.companionGrid.quantity, id: \.self) { index in
                Button {
                    modelView.toggleHideCompanionView(for: index)
                } label: {
                    Text("Toggle hide \(index + 1)")
                }
                
            }
        }
        .opacity(modelView.isPlaying && modelView.hasCompanionView ? 1 : 0)
        .disabled(!modelView.isPlaying)
    }
    
    private var mediaControlsView: some View {
        HStack(spacing: 50) {
            Button {
                if modelView.isPlaying { modelView.stop() } else { modelView.requestAds() }
            } label: {
                Text(!modelView.isPlaying ? "Request ad(s)" : "Stop")
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
    ClientSideExampleView(modelView: ClientSideModelView(zoneIds: ["17161"], companionZone: "17863"))
}
