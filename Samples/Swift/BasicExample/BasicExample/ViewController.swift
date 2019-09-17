//
//  ViewController.swift
//  BasicExample
//
//  Created by Teodor Cristea on 16/09/2019.
//  Copyright © 2019 Inc, AdsWizz. All rights reserved.
//

import UIKit
import AudioAdSDK
import AVFoundation

class ViewController: UIViewController {
    var adManager: AdManager?
    lazy var companionView: AdCompanionView? = {
        let view = AdCompanionView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.delegate = self
        return view
    }()
    lazy var playedTime: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.clear
        label.adjustsFontForContentSizeCategory = true
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.black
        label.font = UIFont(descriptor: UIFontDescriptor.init(), size: 20)
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
        label.alpha = 0
        return label
    }()
    lazy var toolbar: UIToolbar = {
       let toolbar = UIToolbar(frame: .zero)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.barStyle = UIBarStyle.default
        
        let requestButton = UIBarButtonItem(title: "Request ads", style: .plain, target: self, action: #selector(requestAds))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let skipButton = UIBarButtonItem(title: "Skip ad(s)", style: .plain, target: self, action: #selector(skipAds))
        toolbar.items = [requestButton, spacer, skipButton]
        return toolbar
    }()
    var audioPlayer = AVAudioPlayer()
    var isPlaying = false
    var timer:Timer!
    
    let adServer = "demo.deliveryengine.adswizz.com"
    let playerId = "Acastiosplayer"
    let zoneId = "12561"
    let companionZones = "12562"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Build UI
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let window = delegate.window
        var top: CGFloat = 0
        var bottom: CGFloat = 0
        if let window = window {
            top = window.safeAreaTop
            bottom = window.safeAreaBottom
        }
        
        view.addSubview(status)
        view.addSubview(toolbar)
        view.addSubview(playedTime)
        let views = ["time": playedTime, "status": status, "bar": toolbar]
        let metrics = ["side": 20, "top": max(20, top), "bottom": bottom]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-side-[time]-side-|", metrics: metrics, views: views as [String : Any]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-side-[status]-side-|", metrics: metrics, views: views as [String : Any]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-0-[bar]-0-|", metrics: metrics, views: views as [String : Any]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-top-[time]-[status]-(>=0)-[bar]-bottom-|", metrics: metrics, views: views as [String : Any]))
        
        // Prepare content playback
        let path = Bundle.main.path(forResource: "content_example", ofType: "mp3")!
        let url = URL(fileURLWithPath: path)
        
        // Start content
        do {
            audioPlayer =  try AVAudioPlayer(contentsOf: url)
            audioPlayer.numberOfLoops = -1
            playContent()
            
        } catch {
            // can't load file
        }
    }
}

extension ViewController: AdManagerDelegate {
    func adManager(_ adManager: AdManager, didReceiveAd ad: AdData?, error: Error) {
        print("ad manager: \(adManager) received ad: \(ad?.id ?? "unknown")")
    }
    
    func adManager(_ adManager: AdManager, didReceiveAdEvent event: AdEvent) {
        print("ad manager: \(adManager) triggered ad event: \(event.stringEvent)")
        
        switch event.event {
        case .didFinishLoading:
            // Ad manager finished loading ad(s)
            // Before playing the ads you should pause your own content
            pauseContent()
            
            // Start playing ad(s)
            self.adManager?.play()
        
        case .didStartPlaying:
            // Ad manager started playing the ad(s)
            // Show a companion ad which will automatically be synced with the ad
            if let view = companionView {
                self.view.addSubview(view)
                let views = ["view": view]
                self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-0@900-[view]-0@900-|", metrics: [:], views: views as [String : Any]))
                self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0@900-[view]-0@900-|", metrics: [:], views: views as [String : Any]))
                
                let height = NSLayoutConstraint.init(item: view,
                                                     attribute: .height,
                                                     relatedBy: .equal,
                                                     toItem: view,
                                                     attribute: .width,
                                                     multiplier: 1.0,
                                                     constant: 0)
                let centerX = NSLayoutConstraint.init(item: view,
                                                      attribute: .centerX,
                                                      relatedBy: .equal,
                                                      toItem: self.view,
                                                      attribute: .centerX,
                                                      multiplier: 1.0,
                                                      constant: 0)
                let centerY = NSLayoutConstraint.init(item: view,
                                                      attribute: .centerY,
                                                      relatedBy: .equal,
                                                      toItem: self.view,
                                                      attribute: .centerY,
                                                      multiplier: 1.0,
                                                      constant: 0)
                self.view.addConstraints([height, centerX, centerY])
            }

        case .didFinishPlaying, .allAdsDidFinishPlaying:
            // Ad manager just finished playing (all) ad(s)
            // Resume content
            playContent()
            
            // Remove companion view
            if let view = companionView {
                view.removeFromSuperview()
            }
            
            // Cleanup
            self.adManager = nil

        default:
            break
        }
    }
}

extension ViewController: AdCompanionViewDelegate {
    func adCompanionViewWillLoadAd(_ adCompanionView: AdCompanionView) {
        print("Received companion event: willLoadAd")
    }
    
    func adCompanionViewDidDisplayAd(_ adCompanionView: AdCompanionView) {
        print("Received companion event: didDisplayAd")
    }
    
    func adCompanionView(_ adCompanionView: AdCompanionView, didFailToDisplayAd error: Error) {
        print("Received companion error: didFailToDisplayAd")
    }
    
    func adCompanionViewOutOfContext(_ adCompanionView: AdCompanionView) {
        print("Received companion event: outOfContext")
    }
    
    func adCompanionView(_ adCompanionView: AdCompanionView, shouldOverrideCompanionClickThrough url: URL?) -> Bool {
        // Return true if you want to handle the click through URL yourself
        // e.g open it up with in-app Safari web view
        // By default it returns false and opens the URL in Safari app
        return false
    }
    
    func adCompanionViewWillLeaveApplication(_ adCompanionView: AdCompanionView) {
        print("Received companion event: willLeaveApp")
    }

}

extension ViewController {
    func playContent() {
        if !isPlaying {
            audioPlayer.play()
            isPlaying = true
            
            timer = Timer.scheduledTimer(timeInterval: 1.0,
                                         target: self,
                                         selector: #selector(updateTime),
                                         userInfo: nil,
                                         repeats: true)
            
            status.alpha = 0
            status.text = "Playing content..."
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           options: [.autoreverse, .repeat] , animations: {
                            self.status.alpha = 1
            }) { finished in }
        }
    }
    
    func pauseContent() {
        if isPlaying {
            audioPlayer.pause()
            isPlaying = false
            status.text = "Content paused..."
            status.layer.removeAllAnimations()
            UIView.animate(withDuration: 0,
                           delay: 0,
                           options: [.beginFromCurrentState] , animations: {
                            self.status.alpha = 1
            }) { finished in }

        }
    }
    
    @objc func updateTime() {
        let currentTime = Int(audioPlayer.currentTime)
        let minutes = currentTime/60
        let seconds = currentTime - minutes * 60
        
        playedTime.text = String(format: "%02d:%02d", minutes,seconds) as String
    }
    
    @objc func requestAds() {
        // Adswizz request ads
        do {
            let adRequest = try AdswizzAdRequest.Builder()
                .with(server: adServer)
                .with(playerId: playerId)
                .with(zoneId: zoneId)
                .with(companionZones: companionZones)
                .with(companionAdsEnabled: true)
                .build()
            let adRequestConnection = AdRequestConnection(for: adRequest)
            adRequestConnection.requestAds { adManager, error in
                if let error = error {
                    print("Ad request connection failed to retrieve ads with error = \(error)")
                } else {
                    // Keep a strong ref to adManager
                    self.adManager = adManager
                    adManager?.delegate = self
                    
                    // Prepare
                    adManager?.prepare()
                }
            }
        } catch {
            print("Oops, the request is not valid")
        }
    }
    
    @objc func skipAds() {
        adManager?.skipAd()
    }
}

extension UIWindow {
    var safeAreaTop: CGFloat {
        var top: CGFloat = 0.0
        if #available(iOS 11.0, *) {
            top = safeAreaInsets.top
        }
        return top
    }
    
    var safeAreaBottom: CGFloat {
        var bottom: CGFloat = 0.0
        if #available(iOS 11.0, *) {
            bottom = safeAreaInsets.bottom
        }
        return bottom
    }
}
