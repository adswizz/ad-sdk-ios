//
//  ModelDescriptionSection.swift
//  AdswizzExamplesCommon
//
//  Created by George Mihoc on 09.06.2026.
//

import SwiftUI

public struct ModelDescriptionSection: View {
    public let title: String?
    public let modelName: String?
    public let modelDescription: String?
    public let adServer: String?
    public let zoneID: String?
    public let companionZones: String?
    public let streamUrl: String?
    public let externalPlayerSwitchEnabled: Bool
    @Binding public var useExternalPlayer: Bool

    public init(
        title: String? = nil,
        modelName: String? = nil,
        modelDescription: String? = nil,
        adServer: String? = nil,
        zoneID: String? = nil,
        companionZones: String? = nil,
        streamUrl: String? = nil,
        externalPlayerSwitchEnabled: Bool = true,
        useExternalPlayer: Binding<Bool>
    ) {
        self.title = title
        self.modelName = modelName
        self.modelDescription = modelDescription
        self.adServer = adServer
        self.zoneID = zoneID
        self.companionZones = companionZones
        self.streamUrl = streamUrl
        self.externalPlayerSwitchEnabled = externalPlayerSwitchEnabled
        self._useExternalPlayer = useExternalPlayer
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let displayTitle = title ?? modelName {
                Text(displayTitle)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            if let modelDescription {
                Text(modelDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if let adServer {
                InfoRow(title: "AdServer:", value: adServer)
            }
            if let zoneID {
                InfoRow(title: "ZoneID:", value: zoneID)
            }
            if let companionZones {
                InfoRow(title: "CompanionZones:", value: companionZones)
            }
            if let streamUrl {
                InfoRow(title: "Stream URL:", value: streamUrl)
            }

            Toggle("Use External Player", isOn: $useExternalPlayer)
                .disabled(!externalPlayerSwitchEnabled)
        }
        .padding()
        #if os(tvOS)
        .background(Color.gray.opacity(0.15))
        #else
        .background(Color(.systemGray6))
        #endif
        .cornerRadius(12)
    }
}
