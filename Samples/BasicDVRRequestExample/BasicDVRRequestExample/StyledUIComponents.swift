//
//  StyledUIComponents.swift
//  BasicDVRRequestExample
//
//  Created by Adrian Manolache on 13.07.2022.
//

import UIKit

class DVRButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        applyStyle()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        applyStyle()
    }
    
    private func applyStyle() {
        layer.cornerRadius = 8
        layer.masksToBounds = true
        backgroundColor = .systemBlue
        setTitleColor(.white, for: .normal)
        setTitleColor(.black, for: .selected)
    }
}

class DVRTextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        applyStyle()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        applyStyle()
    }
    
    private func applyStyle() {
        layer.backgroundColor = UIColor.white.cgColor
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = 0.0
        layer.cornerRadius = 5
        layer.masksToBounds = false
        layer.shadowRadius = 2.0
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 1.0
    }
}

class RoundedCornersView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        applyStyle()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        applyStyle()
    }
    
    private func applyStyle() {
        layer.cornerRadius = 8
        layer.masksToBounds = true
    }
}
