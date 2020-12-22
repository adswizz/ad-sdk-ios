//
//  ViewController.swift
//  BasicVideoAdExample
//
//  Created by Teodor Cristea on 21/10/2020.
//

import UIKit
import AdswizzSDK
import AVFoundation

class ViewController: UIViewController {
    
    // Video view
    lazy var videoView: VideoView = {
        let video = AdVideoView(frame: .zero)
        video.translatesAutoresizingMaskIntoConstraints = false
        video.backgroundColor = .black

        let view = VideoView(video)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.delegate = self
        return view
    }()
    
    // Trigger request ads / stop ads button
    lazy var actionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.clear
        button.titleLabel?.font = .boldSystemFont(ofSize: 17)
        button.setTitle("Request ads", for: .normal)
        button.setTitle("Stop ads", for: .selected)
        button.tintColor = .white
        button.addTarget(self, action: #selector(actionButonTapped), for: .touchUpInside)
        
        let insets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
        button.setBackgroundImage(UIImage.from(color: UIColor.blue.withAlphaComponent(0.5)).resizableImage(withCapInsets: insets), for: .normal)
        button.setBackgroundImage(UIImage.from(color: UIColor.blue.withAlphaComponent(0.4)).resizableImage(withCapInsets: insets), for: .highlighted)
        button.contentVerticalAlignment = .top
        button.titleEdgeInsets.top = 15
        
        return button
    }()

    // Model for ads setup
    lazy var model: Model = {
        let model = Model()
        model.adDatasource = self
        model.adDelegate = self
        return model
    }()
    
    // Internal
    private let actionButtonBaseHeight: CGFloat = 54.0
    private var actionButtonHeightConstraint: NSLayoutConstraint?
    var skipState: SkipState = .initial
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Video ads"
        
        view.addSubview(actionButton)
        
        // Add action button constraints
        let heightConstraint = actionButton.heightAnchor.constraint(equalToConstant: actionButtonBaseHeight + view.safeAreaInsets.bottom)
        actionButtonHeightConstraint = heightConstraint
        NSLayoutConstraint.activate([
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            actionButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            heightConstraint
        ])        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        actionButtonHeightConstraint?.constant = actionButtonBaseHeight + view.safeAreaInsets.bottom/2
    }
}

extension ViewController {
    @objc func actionButonTapped() {
        let selected = actionButton.isSelected
        if selected {
            model.stop()
        } else {
            do {
                try model.requestAds()
            } catch  {
                print(error)
                return
            }
        }
        actionButton.isSelected = !selected
    }
}

extension ViewController {
    func showVideoView() {
        if videoView.superview != nil {
            return
        }
        view.addSubview(videoView)
        videoView.alpha = 0
        
        let centerXConstraint = videoView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: view.frame.width/2)
        centerXConstraint.identifier = "centerXConstraint"
        
        let centerYConstraint = videoView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0)
        centerYConstraint.identifier = "centerYConstraint"

        let widthConstraint = videoView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85)
        widthConstraint.identifier = "widthConstraint"

        let heightConstraint = videoView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3)
        heightConstraint.identifier = "heightConstraint"
        
        NSLayoutConstraint.activate([
            centerXConstraint,
            centerYConstraint,
            widthConstraint,
            heightConstraint
        ])
        
        videoView.updateConstraintsIfNeeded()
        videoView.setNeedsLayout()
        videoView.layoutIfNeeded()
        
        DispatchQueue.main.async {
            centerXConstraint.constant = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
                self.videoView.alpha = 1
            }) { _ in }
        }
    }
    
    func dismissVideoView() {
        let dismiss = { [ weak self] in
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [.beginFromCurrentState], animations: {
                self?.videoView.alpha = 0
            }) { _ in
                self?.videoView.removeFromSuperview()
            }
        }
        if videoView.isFullscreen {
            videoView.animateFullScreenOrReverse(from: view) {
                dismiss()
            }
        } else {
            dismiss()
        }
    }
}

extension UIImage {
    // Creates a 1x1 image fiilled with `color`.
    static func from(color: UIColor) -> UIImage {
        let size = CGSize(width: 1, height: 1)
        return UIGraphicsImageRenderer(size: size).image(actions: { (context) in
            context.cgContext.setFillColor(color.cgColor)
            context.fill(.init(origin: .zero, size: size))
        })
    }
}
