//
//  ActionButtonsSection.swift
//  BasicAdRequestExample
//
//  Created by George Mihoc on 14.01.2026.
//  Copyright © 2026 Inc, AdsWizz. All rights reserved.
//

import AdswizzExamplesCommon
import SwiftUI

struct ActionButtonsSection: View {
    var requestAdsAction: (() -> Void)?
    var skipAdsAction: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 30) {
            ActionButtonView(title: "Request ad(s)", action: requestAdsAction)
            ActionButtonView(title: "Skip ad(s)", action: skipAdsAction)
        }
        .padding()
    }
}
