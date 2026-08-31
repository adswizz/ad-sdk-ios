//
//  MainViewModel.swift
//  BasicTrackingPermissionExample
//
//  Created by George Mihoc on 22.01.2026.
//

import SwiftUI
import UIKit
import AdswizzSDK
import AdswizzExamplesCommon
import AppTrackingTransparency

@MainActor class MainViewModel: ObservableObject, Loggable {
    @Published var logs: String = ""
    @Published var title: String = "Tracking Permission"
    @Published var showTrackingController: Bool = false
    @Published var showStatusAlert: Bool = false
    @Published var statusAlertMessage: String = ""

    private var trackingController: TrackingPermissionController?

    var canPresent: Bool {
        TrackingPermissionController.canPresentController()
    }

    func presentTrackingPermission(isDarkMode: Bool) {
        guard canPresent else {
            let status = ATTrackingManager.trackingAuthorizationStatus
            let statusDescription: String
            switch status {
            case .authorized: statusDescription = "authorized"
            case .denied: statusDescription = "denied"
            case .restricted: statusDescription = "restricted"
            case .notDetermined: statusDescription = "notDetermined"
            @unknown default: statusDescription = "unknown (\(status.rawValue))"
            }
            // iOS shows the ATT prompt only once; once decided it can only be changed from Settings.
            addLog("Tracking permission already decided (status: \(statusDescription)).")
            statusAlertMessage = "Tracking permission is already \(statusDescription). iOS shows the system prompt only once — to change it, open Settings."
            showStatusAlert = true
            return
        }

        showTrackingController = true
    }

    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
    
    func makeTrackingController(isDarkMode: Bool) -> TrackingPermissionController {
        let logo = customLogo(isDarkMode: isDarkMode)
        let controller = TrackingPermissionController.trackingController(
            title: "Tired of hearing irrelevant ads?",
            headerImage: logo
        )
        controller.delegate = self
        trackingController = controller
        return controller
    }

    private func customLogo(isDarkMode: Bool) -> UIImage? {
        var logo = UIImage.logo?.withRenderingMode(.alwaysOriginal)
        if isDarkMode {
            logo = logo?.tinted(with: .white)
        }
        return logo
    }
}

extension MainViewModel: TrackingPermissionControllerDelegate {
    func tracking(_ controller: TrackingPermissionController, didFinishWith status: TrackingStatus) {
        addLog("[Tracking permission] finished with status: \(status.stringValue)")
    }
    
    func tracking(_ controller: TrackingPermissionController, didFailed error: Error) {
        addLog("[Tracking permission] error: \(error.localizedDescription)")
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
    nonisolated(unsafe) static var logo = UIImage(named: "tracking_logo")
    
    func tinted(with color: UIColor) -> UIImage? {
        defer { UIGraphicsEndImageContext() }
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.set()
        withRenderingMode(.alwaysTemplate).draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
