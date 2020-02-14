//
//  UIWindow+SafeArea.swift
//  BasicAdRequestExample
//
//  Created by Teodor Cristea on 17/09/2019.
//  Copyright © 2020 Inc, AdsWizz. All rights reserved.
//

import UIKit

extension UIWindow {
    var safeAreaTop: CGFloat {
        var top: CGFloat = 0.0
        if #available(iOS 11.0, *) {
            top = safeAreaInsets.top
        }
        return top
    }
    
    var safeAreaBottom: CGFloat {
        var bottom: CGFloat = 0.0
        if #available(iOS 11.0, *) {
            bottom = safeAreaInsets.bottom
        }
        return bottom
    }
}
