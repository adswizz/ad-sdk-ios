//
//  ExpandedTouchAreaButton.swift
//  BasicVideoAdExample
//
//  Created by Teodor Cristea on 25/11/2020.
//

import UIKit
import Foundation

@IBDesignable class ExpandedTouchAreaButton: UIButton {
    /// Defines the insets for the hit area in all directions. Defaults to CGPointZero.
    /// Note that we need to set negative values since the insets are used as rect insets for button's current bounds.
    @IBInspectable var hitAreaInsets: CGPoint = .zero
    
    /// Overrides pointInside:withEvent: to get a chance to respond first before the touch is consumed.
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return bounds.insetBy(dx: hitAreaInsets.x, dy: hitAreaInsets.y).contains(point)
    }
}

extension UIButton {
    func addPadding(horizontal: CGFloat, vertical: CGFloat) {
        titleEdgeInsets = UIEdgeInsets(top: -vertical, left: -horizontal, bottom: -vertical, right: -horizontal)
        contentEdgeInsets = UIEdgeInsets(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }
}
