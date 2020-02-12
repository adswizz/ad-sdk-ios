//
//  ViewController.swift
//  BasicExample
//
//  Created by Teodor Cristea on 16/09/2019.
//  Copyright © 2019 Inc, AdsWizz. All rights reserved.
//

import UIKit
import AdswizzSDK
import AVFoundation

class ViewController: UIViewController {
    var adManager: AdManager?
    var adConnection: AdRequestConnection?
    
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
    let zoneId = "12561"
    let companionZones = "12562"

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Request ads"
        
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
        // Cancel current connection if running
        adConnection?.cancel()
        
        // Adswizz request ads
        do {
            let adRequest = try AdswizzAdRequest.Builder()
                .with(server: adServer)
                .with(zoneId: zoneId)
                .with(companionZones: companionZones)
                .build()
            adConnection = try AdRequestConnection(for: adRequest)
            adConnection?.requestAds { adManager, error in
                if let error = error {
                    print("Ad request connection failed to retrieve ads with error = \(error)")
                } else {
                    // Keep a strong ref to adManager
                    self.adManager = adManager
                    adManager?.delegate = self
                    
                    // Prepare
                    adManager?.prepare()
                    
                    // Cleanup
                    self.adConnection = nil
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

