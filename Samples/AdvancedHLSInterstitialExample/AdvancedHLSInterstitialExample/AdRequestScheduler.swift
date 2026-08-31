//
//  AdRequestScheduler.swift
//  AdvancedHLSInterstitialExample
//
//  Created by George Mihoc on 18.12.2024.
//

import AdswizzSDK

// The result for fetching ads from Adswizz AdServer.
typealias AdRequestResult = Result<AdManager, Error>

//Scheduler implementation for adRequests that each fetch an AdManager
@MainActor protocol AdRequestScheduler {
    var scheduleFired: ((AdRequestConfig) -> Void)? { get set }
    var scheduleFinished: ((AdRequestResult, AdRequestConfig) -> Void)? { get set }
    func isScheduled(_ adRequest: AdRequestConfig) -> Bool
    func schedule(adRequest: AdRequestConfig)
    func unschedule(adRequest: AdRequestConfig)
    func unscheduleAll()
}

@MainActor class AdRequestSchedulerImpl {
    private var schedules: [ObjectIdentifier: Timer?] = [:]
    private var connections: [ObjectIdentifier: AdRequestConnection?] = [:]
    var scheduleFired: ((AdRequestConfig) -> Void)? = nil
    var scheduleFinished: ((AdRequestResult, AdRequestConfig) -> Void)? = nil
    
    @objc private func fireTimer(timer: Timer) {
        guard let context = timer.userInfo as? [String: AdRequestConfig],
              let adRequestConfig = context["adRequestConfig"] else {
            return
        }
        unschedule(adRequest: adRequestConfig)
        scheduleFired?(adRequestConfig)
        requestAds(for: adRequestConfig)
    }
}

extension AdRequestSchedulerImpl: AdRequestScheduler {
    func isScheduled(_ adRequest: AdRequestConfig) -> Bool {
        return schedules.filter { $0.key == ObjectIdentifier(adRequest) }.first != nil
    }
    
    func schedule(adRequest: AdRequestConfig) {
        if isScheduled(adRequest) {
            return
        }
        let context = ["adRequestConfig": adRequest]
        let timeOffset = adRequest.interstitialConfig.requestTimeOffset
        let timer = Timer(timeInterval: timeOffset, target: self, selector: #selector(fireTimer), userInfo: context, repeats: false)
        schedules[ObjectIdentifier(adRequest)] = timer
        
        RunLoop.current.add(timer, forMode: .common)
    }
    
    func unschedule(adRequest: AdRequestConfig) {
        if !isScheduled(adRequest) {
            return
        }
        guard
            let schedule = schedules.filter({ $0.key == ObjectIdentifier(adRequest) }).first,
            let timer = schedule.value else {
            return
        }
        
        if timer.isValid {
            timer.invalidate()
        }
        schedules = schedules.filter { $0.key != ObjectIdentifier(adRequest) }
    }
    
    func unscheduleAll() {
        schedules.compactMap {
            guard let context = $0.value?.userInfo as? [String: AdRequestConfig] else {
                return nil
            }
            return context["adRequestConfig"]
        }.forEach { unschedule(adRequest: $0) }
    }
}

extension AdRequestSchedulerImpl {
    func requestAds(for adRequestConfig: AdRequestConfig) {
        let existingAdConnection = adRequestConnection(for: adRequestConfig)
        existingAdConnection?.cancel()
        
        do {
            let adRequest = try adRequestConfig.adswizzAdRequest()
            let adConnection = try AdRequestConnection(for: adRequest)
            storeAdRequestConnection(adConnection, for: adRequestConfig)

            Task { [weak self] in
                do {
                    let adManager = try await adConnection.requestAds()
                    self?.scheduleFinished?(AdRequestResult.success(adManager), adRequestConfig)
                } catch {
                    self?.scheduleFinished?(AdRequestResult.failure(error), adRequestConfig)
                }
                self?.removeAdRequestConnection(for: adRequestConfig)
            }
        } catch {
            self.scheduleFinished?(AdRequestResult.failure(error), adRequestConfig)
        }
    }
    
    private func adRequestConnection(for adRequest: AdRequestConfig) -> AdRequestConnection? {
        return connections.filter({ $0.key == ObjectIdentifier(adRequest) }).first?.value
    }
    
    private func storeAdRequestConnection(_ adConnection: AdRequestConnection, for adRequest: AdRequestConfig) {
        connections[ObjectIdentifier(adRequest)] = adConnection
    }
    
    private func removeAdRequestConnection(for adRequest: AdRequestConfig) {
        connections = connections.filter { $0.key != ObjectIdentifier(adRequest) }
    }
}
