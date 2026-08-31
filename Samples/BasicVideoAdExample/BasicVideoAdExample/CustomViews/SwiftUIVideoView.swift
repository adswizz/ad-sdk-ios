//
//  SwiftUIVideoView.swift
//  BasicVideoAdExample
//
//  Created by George Mihoc on 16.01.2026.
//

import AdswizzSDK
import AdswizzExamplesCommon
import SwiftUI

struct SwiftUIVideoView: View {
    let videoView: AdVideoView
    
    @Binding var skipState: SkipState
    @Binding var isFullscreen: Bool
    @Binding var isLoading: Bool
    @Binding var showSkipButton: Bool
    
    var onSkipTapped: () -> Void
    var onDoubleTap: () -> Void
    
    var body: some View {
        ZStack {
            AdswizzAdVideoView(videoView: videoView, isFullscreen: $isFullscreen)
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
            
            if showSkipButton {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        skipButton
                            .padding(.trailing, 15)
                            .padding(.bottom, 20)
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(count: 2, perform: onDoubleTap)
        .cornerRadius(isFullscreen ? 0 : 12)
        .shadow(color: .black.opacity(0.8), radius: 4)
    }
    
    @ViewBuilder
    private var skipButton: some View {
        Button(action: onSkipTapped) {
            Text(skipButtonTitle)
                .font(.system(size: 15))
                .foregroundColor(.white)
                .padding(.horizontal, skipButtonPadding)
                .padding(.vertical, skipButtonPadding > 0 ? 7 : 0)
                .background(skipButtonBackground)
                .cornerRadius(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(skipButtonBorderColor, lineWidth: skipButtonBorderWidth)
                )
        }
        .disabled(!isSkipEnabled)
    }
    
    private var isSkipEnabled: Bool {
        guard case .active = skipState else { return false }
        return true
    }
    
    private var skipButtonTitle: String {
        switch skipState {
        case .initial, .active: return "Skip ad"
        case let .inactive(value): return "Skip ad in \(value)s"
        }
    }
    
    private var skipButtonPadding: CGFloat {
        switch skipState {
        case .active, .initial: return 20
        case .inactive: return 0
        }
    }
    
    private var skipButtonBackground: Color {
        switch skipState {
        case .active, .initial: return Color.white.opacity(0.8)
        case .inactive: return Color.clear
        }
    }
    
    private var skipButtonBorderColor: Color {
        switch skipState {
        case .active, .initial: return Color.gray
        case .inactive: return Color.clear
        }
    }
    
    private var skipButtonBorderWidth: CGFloat {
        switch skipState {
        case .active, .initial: return 1
        case .inactive: return 0
        }
    }
}
