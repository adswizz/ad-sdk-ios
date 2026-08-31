//
//  StatusSection.swift
//  AdswizzExamplesCommon
//
//  Created by George Mihoc on 09.06.2026.
//  Copyright © 2026 Adswizz. All rights reserved.
//

import SwiftUI

public struct StatusSection: View {
    public let version: String
    public let status: String
    public let playedTime: String?
    
    public init(version: String, status: String, playedTime: String? = nil) {
        self.version = version
        self.status = status
        self.playedTime = playedTime
    }
    
    public var body: some View {
        VStack(spacing: playedTime != nil ? 10 : 30) {
            HStack {
                Text(version)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            if let playedTime {
                Text(playedTime)
                    .fontWeight(.medium)
            }

            Text(status)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}
