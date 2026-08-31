//
//  LogsScrollView.swift
//  AdswizzExamplesCommon
//
//  Created by George Mihoc on 16.06.2026.
//

import SwiftUI

public struct LogsScrollView: View {
    let logs: String
    let font: Font

    public init(
        logs: String,
        font: Font = .system(size: 17, weight: .bold)
    ) {
        self.logs = logs
        self.font = font
    }

    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                Text(logs)
                    .font(font)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .id("bottom")
            }
            .onChange(of: logs) { _ in
                withAnimation {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
        }
    }
}
