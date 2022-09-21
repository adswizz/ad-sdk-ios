//
//  StyledUIComponents.swift
//  BasicPodcastExample
//
//  Created by Adrian Manolache on 15.07.2022.
//

import UIKit

class StyledButton: UIButton {
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
        setTitleColor(.white, for: .selected)
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

class RoundedCornersStackView: UIStackView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        applyStyle()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        applyStyle()
    }

    private func applyStyle() {
        layer.cornerRadius = 8
        layer.masksToBounds = true
    }
}


