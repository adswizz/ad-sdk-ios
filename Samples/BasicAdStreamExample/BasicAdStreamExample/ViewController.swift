//
//  ViewController.swift
//  BasicAdStreamExample
//
//  Created by Teodor Cristea on 12/02/2020.
//  Copyright © 2020 Inc, AdsWizz. All rights reserved.
//

import UIKit
import AdswizzSDK

class ViewController: UIViewController {
    var extPlayerToggle: UISwitch?
    
    var model: Model = {
        return Model()
    }()
    
    lazy var companionView: AdCompanionView = {
        let view = AdCompanionView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.1)
        view.delegate = self
        return view
    }()
    lazy var companionViewLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.clear
        label.adjustsFontForContentSizeCategory = true
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.black
        label.font = UIFont(descriptor: UIFontDescriptor.init(), size: 14)
        label.text = "Ad companion view"
        return label
    }()
    lazy var status: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.clear
        label.adjustsFontForContentSizeCategory = true
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.black
        label.font = UIFont(descriptor: UIFontDescriptor.init(), size: 18)
        label.text = "Tap 'Play stream' to start..."
        return label
    }()
    lazy var playStopButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.roundedRect)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.clear
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.textAlignment = NSTextAlignment.center
        button.titleLabel?.font = UIFont(descriptor: UIFontDescriptor.init(), size: 16)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.white, for: .selected)
        button.setTitle("Play stream", for: .normal)
        button.setTitle("Stop stream", for: .selected)
        button.addTarget(self, action: #selector(playStopStream(button:)), for: UIControl.Event.touchUpInside)
        return button
    }()
    lazy var pauseResumeButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.roundedRect)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.clear
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.textAlignment = NSTextAlignment.center
        button.titleLabel?.font = UIFont(descriptor: UIFontDescriptor.init(), size: 16)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.white, for: .selected)
        button.setTitle("Pause stream", for: .normal)
        button.setTitle("Resume stream", for: .selected)
        button.addTarget(self, action: #selector(pauseResumeStream(button:)), for: UIControl.Event.touchUpInside)
        return button
    }()
    lazy var skipAdButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.roundedRect)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.clear
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.textAlignment = NSTextAlignment.center
        button.titleLabel?.font = UIFont(descriptor: UIFontDescriptor.init(), size: 16)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.white, for: .selected)
        button.setTitle("Skip ad", for: .normal)
        button.setTitle("Skip ad", for: .selected)
        button.isSelected = true
        button.isHidden = true
        button.addTarget(self, action: #selector(skipAd(button:)), for: UIControl.Event.touchUpInside)
        return button
    }()
    lazy var horizontalStackView: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = UIStackView.spacingUseSystem
        return stack
    }()
    lazy var verticalStackView: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = UIStackView.spacingUseSystem
        return stack
    }()
    lazy var externalPlayerToggle: UISwitch = {
        let toggle = UISwitch(frame: .zero)
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.addTarget(self, action: #selector(externalPlayerSwitchChanged), for: .valueChanged)
        return toggle
    }()
    lazy var externalPlayerLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.clear
        label.adjustsFontForContentSizeCategory = true
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.black
        label.font = UIFont(descriptor: UIFontDescriptor.init(), size: 18)
        label.text = "Use external player"
        return label
    }()
    lazy var togglePlayerStackView: UIStackView = {
        self.extPlayerToggle = externalPlayerToggle
        let stack = UIStackView(arrangedSubviews: [externalPlayerLabel, externalPlayerToggle])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fillProportionally
        stack.spacing = UIStackView.spacingUseSystem
        return stack
    }()
    
    @objc func externalPlayerSwitchChanged(_ mySwitch: UISwitch) {
        model.isUsingExternalPlayer = mySwitch.isOn
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Ad streaming" + " - AdsWizz SDK v" + Bundle(for: AdswizzAdRequest.self).version
        
        // Arrange buttons
        horizontalStackView.addArrangedSubview(playStopButton)
        horizontalStackView.addArrangedSubview(skipAdButton)
        horizontalStackView.addArrangedSubview(pauseResumeButton)
        
        // Arrange all content
        verticalStackView.addArrangedSubview(status)
        verticalStackView.addArrangedSubview(companionView)
        verticalStackView.addArrangedSubview(horizontalStackView)
        verticalStackView.addArrangedSubview(togglePlayerStackView)
        view.addSubview(companionViewLabel)
        view.addSubview(verticalStackView)
        
        // Set constraints
        NSLayoutConstraint.activate([
            companionViewLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            companionViewLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            companionView.heightAnchor.constraint(equalTo: companionView.widthAnchor),
            verticalStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            verticalStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            verticalStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

extension ViewController {
    @objc func playStopStream(button: UIButton) {
        defer { button.isSelected = model.state == .playing }
        switch model.state {
        case .playing, .paused:
            model.stop()
            pauseResumeButton.isSelected = false
            extPlayerToggle?.isUserInteractionEnabled = true
        case .stopped:
            do {
                model.adBreakDelegate = self
                model.streamDelegate = self
                try model.play()
                extPlayerToggle?.isUserInteractionEnabled = false
            } catch {
                print("Failed to play ad stream. Reason = \(error)")
            }
        }
    }
    
    @objc func pauseResumeStream(button: UIButton) {
        if !model.isReadyToPlay {
            return
        }
        button.isSelected = !button.isSelected
        switch model.state {
        case .playing:
            model.pause()
        case .paused:
            model.resume()
        default:
            break
        }
    }
    
    @objc func skipAd(button: UIButton) {
        model.skipAd()
    }
}
