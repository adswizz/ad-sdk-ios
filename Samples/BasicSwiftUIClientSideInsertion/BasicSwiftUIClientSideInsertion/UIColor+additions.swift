//
//  UIColor+additions.swift
//  BasicSwiftUIClientSideInsertion
//
//  Created by Adrian Manolache on 16.06.2022.
//

import SwiftUI

extension UIColor {
    var color: Color {
        get {
            let rgbColours = self.cgColor.components
            return Color(
                red: Double(rgbColours![0]),
                green: Double(rgbColours![1]),
                blue: Double(rgbColours![2])
            )
        }
    }
}
