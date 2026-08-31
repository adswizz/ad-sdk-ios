//
//  ViewController.swift
//  BasicAdRequestExample
//
//  Created by Teodor Cristea on 16/09/2019.
//  Copyright © 2020 Inc, AdsWizz. All rights reserved.
//

import UIKit
import AdswizzSDK
import AdswizzExamplesCommon
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet var adswizzSDKVersion: UILabel!
    @IBOutlet var playedTime: UILabel!
    @IBOutlet var status: UILabel!
    @IBOutlet var modelName: UILabel!
    @IBOutlet var adServer: UILabel!
    @IBOutlet var zoneID: UILabel!
    @IBOutlet var companionZones: UILabel!
    @IBOutlet var modelDescription: UILabel!
    @IBOutlet var externalPlayerSwitch: UISwitch!
    
    var adManager: AdManager?
    var adConnection: AdRequestConnection?
    
    var externalPlayer = ExternalMediaPlayer()
    var audioPlayer = AVAudioPlayer()
    var isPlaying = false
    var timer:Timer!
    var model: AdRequestConfigModelProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Request AdsWizz ads"
        
        adswizzSDKVersion.text = "AdsWizz SDK v" + Bundle(for: AdswizzAdRequest.self).version
        
        // Prepare model
        /// Check AdswizzSDKConfig.plist for all the values.
        /// Possible values: "NormalAds", "InteractiveAds", "AskPermissionAds", "InteractiveVoiceAds"
        model = buildFromConfigFile(scenarioName: "NormalAds")
        
        // Update UI with model values
        modelName.text = model?.modelName
        adServer.text = model?.adServer
        zoneID.text = model?.zoneId
        companionZones.text = model?.companionZones
        modelDescription.text = model?.description
        
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
                .with(companionZoneIds: companionZones.components(separatedBy: CharacterSet(charactersIn: ",")).compactMap { Int($0) })
                .build()
            let connection = try AdRequestConnection(for: adRequest)
            adConnection = connection

            Task { [weak self] in
                guard let self else { return }
                do {
                    let adManager = try await connection.requestAds()

                    // Keep a strong ref to adManager
                    self.adManager = adManager
                    adManager.delegate = self
                    adManager.datasource = self
                    adManager.interactiveDelegate = self

                    if self.externalPlayerSwitch.isOn == true {
                        let settings = AdManagerSettings()
                        settings.player = self.externalPlayer
                        adManager.adManagerSettings = settings
                    }

                    // Prepare
                    adManager.prepare()

                    // Send watch message
                    self.model?.watchSupport?.sendMessage(.playingAds)
                } catch {
                    print("Ad request connection failed to retrieve ads with error = \(error)")
                }

                // Cleanup
                self.adConnection = nil
            }
        } catch {
            print("Oops, the request is not valid")
        }
    }
    
    @IBAction func skipAds() {
        adManager?.skipAd()
    }
}

