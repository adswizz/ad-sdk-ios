//
//  ViewController.swift
//  BasicAdRequestExample
//
//  Created by Teodor Cristea on 16/09/2019.
//  Copyright © 2020 Inc, AdsWizz. All rights reserved.
//

import UIKit
import AdswizzSDK
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet var playedTime: UILabel!
    @IBOutlet var status: UILabel!
    
    var adManager: AdManager?
    var adConnection: AdRequestConnection?
    
    lazy var companionView: AdCompanionView? = {
        let view = AdCompanionView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.delegate = self
        return view
    }()
    
    var audioPlayer = AVAudioPlayer()
    var isPlaying = false
    var timer:Timer!
    var model: ViewControllerModelProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Request ads"
        
        // Prepare model
        model = build()
        
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
            
            // Send watch message if paired
            model?.watchSupport?.sendMessage(.playingContent)
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
    
    @IBAction func requestAds() {
        
        //stop and clean current adManager instance
        adManager?.skipAd()
        adManager = nil
        
        guard
            let adServer = model?.adServer,
            let zoneId = model?.zoneId,
            let companionZones = model?.companionZones else {
                return
        }
        
        // Cancel current connection if running
        adConnection?.cancel()
        
        // Adswizz request ads
        do {
            
            let zoneBuilder = AdswizzAdZone.Builder()
            let zone = try zoneBuilder
                .with(zoneId: zoneId)
                .build()

            let adRequest = try AdswizzAdRequest.Builder()
                .with(server: adServer)
                .with(zones: [zone])
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
                    adManager?.datasource = self
                    adManager?.interactiveDelegate = self
                    
                    // Prepare
                    adManager?.prepare()
                    
                    // Cleanup
                    self.adConnection = nil
                    
                    // Send watch message
                    self.model?.watchSupport?.sendMessage(.playingAds)
                }
            }
        } catch {
            print("Oops, the request is not valid")
        }
    }
    
    @IBAction func skipAds() {
        adManager?.skipAd()
    }
}

