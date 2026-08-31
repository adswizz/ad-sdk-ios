//
//  InfoRow.swift
//  AdswizzExamplesCommon
//
//  Created by George Mihoc on 09.06.2026.
//

import SwiftUI

public struct InfoRow: View {
    public let title: String?
    public let value: String?

    public init(title: String?, value: String?) {
        self.title = title
        self.value = value
    }

    public var body: some View {
        HStack(spacing: 4) {
            Text(title ?? "")
                .fontWeight(.medium)
                .truncationMode(.middle)
                .lineLimit(1)
            Text(value ?? "")
                .foregroundColor(.blue)
                .truncationMode(.middle)
                .lineLimit(1)
            Spacer()
        }
        .font(.subheadline)
    }
}
