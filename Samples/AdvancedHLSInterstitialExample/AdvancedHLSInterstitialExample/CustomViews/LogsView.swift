//
//  LogsView.swift
//  AdvancedHLSInterstitialExample
//
//  Created by George Mihoc on 20.12.2024.
//

import SwiftUI

protocol Loggable {
    var title: String { get }
    var subtitle: String? { get }
    var message: String? { get }
}

struct LogsView: View {
    let logs: [Loggable]
    
    var body: some View {
        VStack(spacing: .zero) {
            logsHeaderView
            logItemsView
        }
    }
    
    private var logsHeaderView: some View {
        HStack {
            Text("Logs")
                .font(.headline)
            Spacer()
        }
        .padding(10)
    }
    
    private var logItemsView: some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(logs.indices, id: \.self) { index in
                        logItemView(for: logs[index])
                        if index < logs.count - 1 {
                            Divider()
                        }
                    }
                }
                .onChange(of: logs.count) { _ in
                    if let lastIndex = logs.indices.last {
                        withAnimation {
                            scrollViewProxy.scrollTo(lastIndex, anchor: .bottom)
                        }
                    }
                }
            }
        }
    }
    
    private func logItemView(for log: Loggable) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: .zero) {
                Text(log.title)
                    .font(.system(size: 13, weight: .bold))
                if let subtitle = log.subtitle {
                    Text(subtitle)
                        .font(.system(size: 13))
                }
            }
            Spacer()
            if let message = log.message {
                Text(message)
                    .font(.system(size: 13))
            }
        }
        .frame(height: 32)
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
    }
}
