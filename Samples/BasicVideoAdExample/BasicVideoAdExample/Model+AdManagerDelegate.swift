//
//  Model+AdManagerDelegate.swift
//  BasicVideoAdExample
//
//  Created by Teodor Cristea on 21/10/2020.
//

import AdswizzSDK

extension Model: AdManagerDelegate {
    func adManager(_ adManager: AdManager, didReceiveAd ad: AdData?, error: Error) {
        print("ad manager: \(adManager) received ad: \(ad?.id ?? "unknown")")
    }
    
    func adManager(_ adManager: AdManager, didReceiveAdEvent event: AdEvent) {
        print("ad manager: \(adManager) triggered ad event: \(event.stringEvent)")
                
        switch event.event {
        case .preparingForPlay:
            // Ad manager started loading current ad
            // Check the ad type to be able to differentiate as soon as possible what kind of ad plays next
            adDelegate?.model(self, didStartLoading: adType(for: event.ad))
            
        case .readyForPlay:
            // Ad manager finished loading current ad
            // Before playing the ad you should pause your own content if any.
            
            // Start playing ad(s)
            self.adManager?.play()
            
        case .didStartPlaying:
            // Ad manager started playing current ad
            adDelegate?.model(self, didStartPlayback: adType(for: event.ad))
            
        case .didFinishPlaying:
            // Ad manager just finished playing current ad
            adDelegate?.model(self, didEndPlayback: adType(for: event.ad))
        
        case .allAdsCompleted:
            // Ad manager just finished playing all ads
            adDelegate?.modelDidCompleteAllAds(self)

        default:
            break
        }
    }
    
    func adManager(_ adManager: AdManager, ad: AdData, didChangedPlayHead playHead: TimeInterval, adDuration duration: TimeInterval) {
        print("ad manager:\(adManager) playhead changed: \(playHead), duration: \(duration)")
        var skipOffset = ad.skipOffset
        if skipOffset == nil {
            skipOffset = self.skipOffset //mocked
        }
        if let skipOffset = skipOffset, playHead < skipOffset.doubleValue {
            let value = Int(skipOffset.doubleValue - playHead)
            adDelegate?.model(self, skipStateChanged: .inactive(value: "\(value)"))
        } else {
            adDelegate?.model(self, skipStateChanged: .active)
        }
        adDelegate?.model(self, playHeadChanged: playHead, duration: duration)
    }
}

extension Model {
    func adType(for ad: AdData?) -> AdType {
        return ad?.adType ?? .audio
    }
}

extension AdVideoState {
    var stringValue: String {
        switch self {
        case .collapsed: return "collapsed"
        case .expanded: return "expanded"
        case .fullscreen: return "fullscreen"
        case .minimized: return "minimized"
        case .normal:
            fallthrough
        @unknown default:
            return "normal"
        }
    }
}
