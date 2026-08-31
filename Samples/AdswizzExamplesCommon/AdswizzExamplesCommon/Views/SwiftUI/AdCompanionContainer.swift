//
//  AdCompanionContainer.swift
//  AdswizzExamplesCommon
//
//  Created by George Mihoc on 09.06.2026.
//  Copyright © 2026 Adswizz. All rights reserved.
//

import SwiftUI

public struct AdCompanionContainer: View {
    public let containerTitle: String?
    public let hasCompanionView: Bool
    
    public init(containerTitle: String? = "Ad Companion View container", hasCompanionView: Bool) {
        self.containerTitle = containerTitle
        self.hasCompanionView = hasCompanionView
    }
    
    public var body: some View {
        ZStack {
            Color.cyan
            VStack(spacing: 0) {
                if let containerTitle {
                    Text(containerTitle)
                        .font(.headline)
                        .foregroundColor(.black)
                }
                
                ZStack {
                    if hasCompanionView {
                        AdswizzAdCompanionView()
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.9))
                    }
                }
                .frame(maxHeight: .infinity)
                .padding()
            }
            .padding(.top, containerTitle != nil ? 12 : 0)
        }
        .padding()
        .frame(maxHeight: .infinity)
    }
}
