//
//  SeekBarView.swift
//  Artemis
//
//  Created by Teodor Cristea on 01.11.2021.
//  Copyright © 2021 AdsWizz. All rights reserved.
//

import Foundation
import UIKit

class SeekSlider: UISlider {
    //To set line height value from IB, 3 px is the default value
    @IBInspectable var trackHeight: CGFloat = 3 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    //To set custom size of track
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let defaultBounds = super.trackRect(forBounds: bounds)
        return CGRect(
            x: defaultBounds.origin.x,
            y: defaultBounds.origin.y + defaultBounds.size.height/2 - trackHeight/2,
            width: defaultBounds.size.width,
            height: trackHeight
        )
    }
}

protocol SeekBarViewDelegate: AnyObject {
    func seekBarView(_ view: SeekBarView, didChangeTracking value: Bool, at sliderValue: Float)
    func seekBarView(_ view: SeekBarView, didChangeSlider value: Float)
}

class SeekBarView: UIView {
    let lengthLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:00"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .right
        return label
    }()
    
    let startLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:00"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .right
        return label
    }()

    lazy var slider: UISlider = {
        let slider = SeekSlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumTrackTintColor = .adswizzPurple
        slider.maximumTrackTintColor = .black
        slider.trackHeight = 3
        
        if #available(iOS 13.0, *) {
            let font = UIFont.systemFont(ofSize: 20)
            let configuration = UIImage.SymbolConfiguration(font: font)
            let image = UIImage(systemName: "circle.fill", withConfiguration: configuration)?.withTintColor(.adswizzPurple, renderingMode: .alwaysOriginal)
            slider.setThumbImage(image, for: .normal)
        } else {
            // Use the default appearance
        }
        
        slider.addTarget(self, action: #selector(handleSliderChange), for: .valueChanged)
        sliderHighlightedObserver = slider.observe(\SeekSlider.isTracking, options: [.old, .new]) { (_, change) in
            if let newValue = change.newValue, let oldValue = change.oldValue, newValue != oldValue {
                self.delegate?.seekBarView(self, didChangeTracking: newValue, at: slider.value)
            }
        }
        return slider
    }()
        
    weak var delegate: SeekBarViewDelegate?
    private var sliderHighlightedObserver: NSKeyValueObservation?
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        backgroundColor = .clear
        
        addSubview(lengthLabel)
        addSubview(startLabel)
        addSubview(slider)
        NSLayoutConstraint.activate([
            lengthLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8),
            lengthLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            startLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            startLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            slider.rightAnchor.constraint(equalTo: lengthLabel.leftAnchor, constant: -3),
            slider.leftAnchor.constraint(equalTo: startLabel.rightAnchor, constant: 3),
            slider.topAnchor.constraint(equalTo: topAnchor),
            slider.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
    }
    
    @objc func handleSliderChange() {
        delegate?.seekBarView(self, didChangeSlider: slider.value)
    }
}

extension UIColor {
    static let adswizzPurple = UIColor(red: 206.0/255.0 , green: 159.0/255.0, blue: 252.0/255.0, alpha: 1.0)
}
