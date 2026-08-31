//
//  PassAddViewControllerRepresentable.swift
//  BasicAdRequestExample
//
//  Created by George Mihoc on 14.01.2026.
//  Copyright © 2026 Inc, AdsWizz. All rights reserved.
//

import PassKit
import SwiftUI

struct PassAddViewControllerRepresentable: UIViewControllerRepresentable {
    let controller: PKAddPassesViewController

    func makeUIViewController(context: Context) -> PKAddPassesViewController {
        controller
    }

    func updateUIViewController(_ uiViewController: PKAddPassesViewController, context: Context) { }
}
