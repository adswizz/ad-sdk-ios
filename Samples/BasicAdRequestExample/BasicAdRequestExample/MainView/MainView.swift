//
//  MainView.swift
//  BasicAdRequestExample
//
//  Created by George Mihoc on 14.01.2026.
//  Copyright © 2026 Inc, AdsWizz. All rights reserved.
//

import AdswizzExamplesCommon
import PassKit
import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel = MainViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    StatusSection(version: viewModel.adswizzSDKVersion,
                                  status: viewModel.status,
                                  playedTime: viewModel.playedTime)
                    AdCompanionContainer(hasCompanionView: viewModel.hasCompanionView)
                    ModelDescriptionSection(
                        modelName: viewModel.model?.modelName,
                        modelDescription: viewModel.model?.description,
                        adServer: viewModel.model?.adServer,
                        zoneID: viewModel.model?.zoneId,
                        companionZones: viewModel.model?.companionZones,
                        externalPlayerSwitchEnabled: viewModel.externalPlayerSwitchEnabled,
                        useExternalPlayer: $viewModel.useExternalPlayer
                    )
                    ActionButtonsSection(requestAdsAction: viewModel.didTapRequestAds,
                                         skipAdsAction: viewModel.didTapSkipAds)
                }
                .frame(minHeight: geometry.size.height)
            }
        }
        .cornerRadius(30)
        .padding(.vertical, 10)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(viewModel.title)
        .sheet(isPresented: $viewModel.isPresentingPassSheet) {
            if let pendingPass = viewModel.pendingPass, let controller = PKAddPassesViewController(pass: pendingPass) {
                PassAddViewControllerRepresentable(controller: controller)
                    .ignoresSafeArea()
            } else {
                EmptyView()
            }
        }
    }
}

#Preview {
    MainView()
}
