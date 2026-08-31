//
//  UIWindow+SafeArea.swift
//  AdswizzExamplesCommon
//
//  Created by George Mihoc on 09.06.2026.
//

import UIKit

extension UIWindow {
    public var safeAreaTop: CGFloat {
        safeAreaInsets.top
    }

    public var safeAreaBottom: CGFloat {
        safeAreaInsets.bottom
    }
}
