//
//  ViewController.swift
//  BasicTrackingPermissionExample
//
//  Created by Teodor Cristea on 25/11/2020.
//

import UIKit
import AdswizzSDK

class ViewController: UIViewController {
    var trackingController: TrackingPermissionController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Show tracking controller", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 17)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc func didTapButton() {
        if TrackingPermissionController.canPresentController() {
            trackingController = TrackingPermissionController.trackingController(title: "Tired of hearing irrelevant ads?", headerImage: customLogo)
            trackingController?.delegate = self
            if let controller = trackingController {
                present(controller, animated: true, completion: nil)
            }
        } else {
            print("Ooops, could not present the tracking permission controller")
        }
    }
}

/// TrackingPermissionControllerDelegate support
extension ViewController: TrackingPermissionControllerDelegate {
    func tracking(_ controller: TrackingPermissionController, didFinishWith status: TrackingStatus) {
        print("[Tracking permission] finished with status: \(status.stringValue)")
    }
    
    func tracking(_ controller: TrackingPermissionController, didFailed error: Error) {
        print("[Tracking permission] error: \(error.localizedDescription)")
    }
}

/// Trait collection support.
extension ViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard let trackingController = trackingController, let image = customLogo else {
            return
        }
        let config = TrackingPermissionConfiguration.Builder().with(headerImage: image).build()
        trackingController.configuration = config
    }
    
    var customLogo: UIImage? {
        var logo = UIImage.logo?.withRenderingMode(.alwaysOriginal)
        if UIScreen.isDarkMode {
            logo = logo?.tinted(with: .white)
        }
        return logo
    }
}

extension TrackingStatus {
    var stringValue: String {
        switch self {
        case .openedSettings: return "openedSettings"
        case .skipped: return "skipped"
        case .delayed: return "delayed"
        case .granted: return "granted"
        case .denied: return "denied"
        case .unknown:
            fallthrough
        @unknown default:
            return "unknown"
        }
    }
}

extension UIImage {
    static var logo = UIImage(named: "tracking_logo")
    
    func tinted(with color: UIColor) -> UIImage? {
        defer { UIGraphicsEndImageContext() }
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.set()
        withRenderingMode(.alwaysTemplate).draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

extension UIScreen {
    static var isDarkMode: Bool {
        if #available(iOS 12.0, *) {
            switch UIScreen.main.traitCollection.userInterfaceStyle {
            case .light: return false
            case .dark: return true
            case .unspecified: return false
            @unknown default:
                return false
            }
        } else {
            return false
        }
    }
}
