//
//  ActionButtonView.swift
//  AdswizzExamplesCommon
//
//  Created by George Mihoc on 09.06.2026.
//

import SwiftUI

public struct ActionButtonView: View {
    public let title: String
    public var action: (() -> Void)?

    public init(title: String, action: (() -> Void)? = nil) {
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button(action: { action?() }) {
            Text(title)
                .foregroundColor(.black)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(25)
                .shadow(color: Color.black.opacity(0.1), radius: 6, y: 4)
        }
    }
}
