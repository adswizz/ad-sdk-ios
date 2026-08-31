//
//  SessionDelegate.swift
//  BasicAdRequestWatchExample
//
//  Created by Teodor Cristea on 04/03/2020.
//  Copyright © 2020 Inc, AdsWizz. All rights reserved.
//

import Foundation
import WatchConnectivity
#if os(iOS)
import AdswizzSDK
import AdswizzExamplesCommon
#elseif os(watchOS)
import AdswizzWatchSDK
// WatchPlaybackState is defined in AdswizzExamplesCommon (iOS only).
// Duplicate it here for the watchOS target.
enum WatchPlaybackState: String, Codable {
    case playingAds
    case playingContent
}
#endif

extension Notification.Name {
    static let activationDidComplete = Notification.Name("ActivationDidComplete")
    static let reachabilityDidChange = Notification.Name("ReachabilityDidChange")
    static let messageReceived = Notification.Name("MessageReceived")
}

@MainActor class SessionDelegate: NSObject {
#if os(iOS)
    let watchSession: WatchSession = AdswizzSDK.shared.watchSession
#elseif os(watchOS)
    let watchSession: WatchSession = AdswizzWatchSDK.shared.watchSession
#endif
    
    override init() {
        super.init()
        watchSession.setDelegate(self)
    }

    // Post a notification on the main thread asynchronously.
    //
    nonisolated private func postNotificationOnMainQueueAsync(name: NSNotification.Name, userInfo: [String: Any]? = nil) {
        nonisolated(unsafe) let userInfo = userInfo
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: name, object: nil, userInfo: userInfo)
        }
    }
}

// Implement WCSessionDelegate methods to receive Watch Connectivity data and notify clients.
// WCsession status changes are also handled here.
//
// WatchConnectivity invokes these callbacks on its own background queue, so they are `nonisolated`
// and hop to the main actor for work that touches the `@MainActor` SDK `watchSession`.
extension SessionDelegate: WCSessionDelegate {
    // Called when WCSession activation state is changed.
    //
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Error while activation: \(error.localizedDescription)")
        }
        
        postNotificationOnMainQueueAsync(name: .activationDidComplete)
    }
    
    // Called when WCSession reachability is changed.
    //
    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        postNotificationOnMainQueueAsync(name: .reachabilityDidChange)
    }
    
    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        nonisolated(unsafe) let message = message
        Task { @MainActor in
            if message.isAdswizzWatchData {
                watchSession.receivedMessage(message)
            }

            guard
                let raw = message["Adswizz Ext"] as? String,
                let state = WatchPlaybackState(rawValue: raw)
            else {
                return
            }
            postNotificationOnMainQueueAsync(name: .messageReceived, userInfo: ["WatchMessage": state.rawValue])
        }
    }
    
    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        nonisolated(unsafe) let applicationContext = applicationContext
        Task { @MainActor in
            if applicationContext.isAdswizzWatchData {
                watchSession.receivedMessage(applicationContext)
            }
        }
    }
    
    // WCSessionDelegate methods for iOS only.
    //
    #if os(iOS)
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {
        print("activationState = \(session.activationState.rawValue)")
    }
    
    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        // Activate the new session after having switched to a new watch.
        WCSession.default.activate()
    }
    
    nonisolated func sessionWatchStateDidChange(_ session: WCSession) {
        print("activationState = \(session.activationState.rawValue)")
    }
    #endif
}

extension SessionDelegate: WatchSessionDelegate {
    func sendMessage(_ data: [String : Any]) {
        if WCSession.default.activationState != .activated {
            return
        }

        if WCSession.default.isReachable {
            WCSession.default.sendMessage(data, replyHandler: nil) { error in
                print("Failed to send data: \(error.localizedDescription)")
            }
        } else {
            print("Sesssion is not reachable this is an SDK error!!!")
        }
    }
    
    func updateApplicationContext(_ data: [String: Any]) {
        if WCSession.default.activationState != .activated {
            return
        }
        
        do {
            try WCSession.default.updateApplicationContext(data)
        } catch {
            print("Failed to update application context: \(error.localizedDescription)!!!")
        }
    }
}

