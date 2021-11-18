//
//  TrackingController.swift
//  BasicSwiftUIClientSideInsertion
//
//  Created by Adrian Manolache on 12.11.2021.
//

import SwiftUI
import UIKit
import AdswizzSDK

struct TrackingController: UIViewControllerRepresentable {
    @Binding var result: TrackingStatus
    
    class Coordinator: NSObject, TrackingPermissionControllerDelegate {
        @Binding var result: TrackingStatus

        init(result: Binding<TrackingStatus>) {
            _result = result
        }

        func tracking(_ controller: TrackingPermissionController, didFinishWith status: TrackingStatus) {
            result = status
            print("result=\(result.rawValue)")
        }
        
        func tracking(_ controller: TrackingPermissionController, didFailed error: Error) {
            print("failed=\(error)")
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(result: $result)
    }
    
    static func canPresentController() -> Bool {
        TrackingPermissionController.canPresentController()
    }
    
    func makeUIViewController(context: Context) -> TrackingPermissionController {
                
        let title = TrackingPermissionUIElement.Builder()
            .with(content: "Tired of irrelevant ads?")
            .with(color: .white)
            .with(font: .trackingTitleFont).build()
        
        let message = TrackingPermissionUIElement.Builder()
            .with(content: "We would like your permission to use your data to deliver you a personalised ad experience and nothing more.")
            .with(font: .trackingMessageFont).build()

        let skip = TrackingPermissionUIElement.Builder()
            .with(content: "Skip")
            .with(color: .white)
            .with(font: .trackingSkipFont).build()
        
        let action = TrackingPermissionUIElement.Builder()
            .with(content: "Grant Permission")
            .with(font: .trackingSkipFont).build()

        let configuration = TrackingPermissionConfiguration.Builder()
            .with(title: title)
            .with(description: message)
            .with(skip: skip)
            .with(action: action)
            .with(headerImage: .logo)
            .with(backgroundColor: .black).build()
        let controller = TrackingPermissionController(configuration: configuration)
        controller.delegate = context.coordinator
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: TrackingPermissionController, context: Context) {
    }
}

extension UIFont {
    static let trackingTitleFont = UIFont.init(name: "Inter-Medium", size: 27) ?? .boldSystemFont(ofSize: 27)
    static let trackingMessageFont = UIFont.init(name: "Inter-Regular", size: 16) ?? .systemFont(ofSize: 16)
    static let trackingSkipFont = UIFont.init(name: "Inter-Regular", size: 18) ?? .systemFont(ofSize: 18)
}

extension UIImage {
    static let logo = UIImage(named: "tracking-logo")?.withRenderingMode(.alwaysTemplate).tinted(with: .white) ?? UIImage()
    
    func tinted(with color: UIColor) -> UIImage? {
        defer { UIGraphicsEndImageContext() }
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.set()
        withRenderingMode(.alwaysTemplate).draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
