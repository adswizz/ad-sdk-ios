//
//  VideoView.swift
//  BasicVideoAdExample
//
//  Created by Teodor Cristea on 17/11/2020.
//

import UIKit
import AdswizzSDK

protocol VideoViewDelegate: AnyObject {
    func videoDidDoubleTap(_ view: VideoView)
    func video(_ view: VideoView, didTapSkip button: UIButton)
}

class VideoView: UIView {
    // The video view
    let videoView: AdVideoView
    
    // Content view
    private var contentView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.layer.masksToBounds = true
        container.layer.cornerRadius = 12
        return container
    }()
    
    // Loader view
    private var loadingView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.color = .white
        return view
    }()

    //skippable video button
    private var skipButton: ExpandedTouchAreaButton = {
        let button = ExpandedTouchAreaButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
        button.hitAreaInsets = CGPoint(x: -20, y: -20)
        return button
    }()

    private(set) var isFullscreen = false {
        didSet {
            // When video player state changes, inform AdswizzSDK for viewability purposes
            videoView.state = isFullscreen ? .fullscreen : .normal
            print("Video player state changed to \(videoView.state.stringValue)")
        }
    }
    private var defaultConstraints: [NSLayoutConstraint] = []
    
    lazy private var doubleTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapHandler))
        gesture.numberOfTapsRequired = 2
        return gesture
    }()
    
    weak var delegate: VideoViewDelegate?
    
    init(_ videoView: AdVideoView) {
        videoView.translatesAutoresizingMaskIntoConstraints = false
        self.videoView = videoView
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        contentView.addSubview(videoView)
        contentView.addSubview(loadingView)
        videoView.addSubview(skipButton)
        contentView.addGestureRecognizer(doubleTapGesture)
        
        let margins = layoutMarginsGuide
        let guide = safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
            contentView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            contentView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            
            videoView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0),
            videoView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            videoView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0),
            videoView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            
            guide.bottomAnchor.constraint(equalToSystemSpacingBelow: skipButton.bottomAnchor, multiplier: 1.0),
            skipButton.rightAnchor.constraint(equalTo: margins.rightAnchor, constant: -15)
        ])
        
        // Add loading view constraints
        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.8
        layer.shadowOffset = .zero
        
        // Register skip button as "friendly" obstruction for viewability purposes
        let obstruction = AdVideoFriendlyObstruction(view: skipButton,
                                                     purpose: .mediaControls,
                                                     detailedReason: "Skip button")
        videoView.register(obstruction)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension VideoView {
    func start() {
        loadingView.startAnimating()
    }
    
    func stop() {
        loadingView.stopAnimating()
    }
}

extension VideoView {
    @objc private func skipButtonTapped() {
        delegate?.video(self, didTapSkip: skipButton)
    }

    func updateSkipButton(with state: SkipState) {
        switch state {
        case .active, .initial:
            skipButton.layer.borderWidth = 1
            skipButton.layer.borderColor = UIColor.darkGray.cgColor
            skipButton.backgroundColor = UIColor.white.withAlphaComponent(0.8)
            skipButton.setTitle("Skip ad", for: .normal)
            skipButton.addPadding(horizontal: 20, vertical: 7)
            skipButton.isEnabled = true
        case .inactive(let value):
            skipButton.layer.borderWidth = 0
            skipButton.layer.borderColor = UIColor.clear.cgColor
            skipButton.backgroundColor = .clear
            skipButton.setTitle("Skip ad in \(value)s", for: .normal)
            skipButton.addPadding(horizontal: 0, vertical: 0)
            skipButton.isEnabled = false
        }
    }
    
    func showSkipButton(_ show: Bool) {
        skipButton.isHidden = !show
    }
}

extension VideoView {
    @objc func doubleTapHandler() {
        delegate?.videoDidDoubleTap(self)
    }
    
    func animateFullScreenOrReverse(from sourceView: UIView, completion: (() -> Void)? = nil) {
        if !isFullscreen {
            isFullscreen = true
            
            guard
                let centerXConstraint = sourceView.constraints.first(where: {$0.identifier == "centerXConstraint"}),
                let centerYConstraint = sourceView.constraints.first(where: {$0.identifier == "centerYConstraint"}),
                let widthConstraint = sourceView.constraints.first(where: {$0.identifier == "widthConstraint"}),
                let heightConstraint = sourceView.constraints.first(where: {$0.identifier == "heightConstraint"})
            else {
                completion?()
                return
            }
            defaultConstraints = [centerXConstraint, centerYConstraint, widthConstraint, heightConstraint]

            let topView = UIApplication.shared.windows.first!
            topView.addSubview(self)

            NSLayoutConstraint.activate([
                leftAnchor.constraint(equalTo: topView.leftAnchor, constant: 0),
                topAnchor.constraint(equalTo: topView.topAnchor, constant: 0),
                rightAnchor.constraint(equalTo: topView.rightAnchor, constant: 0),
                bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: 0)
            ])
            
            UIView.animate(withDuration: 0.3) {
                topView.layoutIfNeeded()
            } completion: { _ in
                completion?()
            }
        } else {
            if defaultConstraints.isEmpty {
                completion?()
                return
            }
            
            isFullscreen = false
            sourceView.addSubview(self)
            
            NSLayoutConstraint.activate(defaultConstraints)
            
            UIView.animate(withDuration: 0.3) {
                sourceView.layoutIfNeeded()
            } completion: { _ in
                completion?()
            }
        }
    }
}
