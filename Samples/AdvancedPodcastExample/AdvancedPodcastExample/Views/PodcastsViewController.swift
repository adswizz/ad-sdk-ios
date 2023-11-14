//
//  PodcastsViewController.swift
//  AdvancedPodcastExample
//
//  Created by Teodor Cristea on 29.08.2023.
//  Copyright © 2023 Adswizz. All rights reserved.
//

import UIKit
import AdswizzSDK

class PodcastsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var playerView: PlayerView!
    var minimizedPlayerView: UIView!
    var bottomConstraint: NSLayoutConstraint!
    var model: AppModel {
        return AppModelInstance
    }
    var podcasts: [PodcastConfig.Podcast] {
        return model.podcasts
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// add the minimized player view
        addMinimizedPlayer()
        model.add(listener: self)
    }    
}

extension PodcastsViewController {
    func addMinimizedPlayer() {
        playerView = PlayerView()
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.backgroundColor = .clear
        
        playerView.seekBar.slider.minimumTrackTintColor = .systemBlue
        let font = UIFont.systemFont(ofSize: 20)
        let configuration = UIImage.SymbolConfiguration(font: font)
        let image = UIImage(systemName: "circle.fill", withConfiguration: configuration)?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
        playerView.seekBar.slider.setThumbImage(image, for: .normal)
        
        minimizedPlayerView = UIView()
        minimizedPlayerView.translatesAutoresizingMaskIntoConstraints = false
        minimizedPlayerView.backgroundColor = .white
        minimizedPlayerView.layer.cornerRadius = 7.0
        minimizedPlayerView.layer.shadowColor = UIColor.gray.cgColor
        minimizedPlayerView.layer.shadowOpacity = 0.5
        minimizedPlayerView.addSubview(playerView)
        view.addSubview(minimizedPlayerView)
        
        bottomConstraint = minimizedPlayerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 170)
        NSLayoutConstraint.activate([
            playerView.leadingAnchor.constraint(equalTo: minimizedPlayerView.leadingAnchor, constant: 20),
            playerView.topAnchor.constraint(equalTo: minimizedPlayerView.topAnchor, constant: 20),
            playerView.bottomAnchor.constraint(equalTo: minimizedPlayerView.bottomAnchor, constant: -24),
            playerView.trailingAnchor.constraint(equalTo: minimizedPlayerView.trailingAnchor, constant: -20),
            
            minimizedPlayerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            bottomConstraint,
            minimizedPlayerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)
        ])
    }
    
    func showMinimizedPlayer() {
        bottomConstraint.constant = 0
        UIView.animate(withDuration: 0.3) { [weak self] in
             self?.view.layoutIfNeeded()
        }
    }
    
    func hideMinimizedPlayer() {
        bottomConstraint.constant = 170
        UIView.animate(withDuration: 0.3) { [weak self] in
             self?.view.layoutIfNeeded()
        }
    }
}

extension PodcastsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PodcastTableViewCell", for: indexPath)
        if let cell = cell as? PodcastTableViewCell {
            let state = model.playingPodcast?.matches(podcast: podcasts[indexPath.row]) ?? false ? model.currentState : .stopped
            cell.configure(with: podcasts[indexPath.row], state: state)
            return cell
        }
        return tableView.dequeueReusableCell(withIdentifier: "PodcastTableViewCell", for: indexPath)
    }
}

extension PodcastsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentPodcast = podcasts[indexPath.row]
        if let playerVC: PlayerViewController = UIStoryboard.create() {
            /// customize player view controller
            playerVC.delegate = self
            playerVC.podcast = currentPodcast
            
            hideMinimizedPlayer()
            let navController = UINavigationController(rootViewController: playerVC)
            /// set the presentation controller delegate
            navController.presentationController?.delegate = self
            navigationController?.present(navController, animated: true)
        }
    }
}

extension PodcastsViewController: AppModelListenerDelegate {
    func appModel(_ appModel: AppModelProtocol, stateWillChange state: Playlist.State, for podcast: PodcastConfig.Podcast) {
        tableView.reloadData()
    }
    
    func appModel(_ appModel: AppModelProtocol, playheadChanged playhead: TimeInterval, duration: TimeInterval, for podcast: PodcastConfig.Podcast) {
    }
    
    func appModel(_ appModel: AppModelProtocol, didEncounterError error: Error, for podcast: PodcastConfig.Podcast) {
    }
    
    func appModel(_ appModel: AppModelProtocol, didStartPlaying ad: AdData, withCompanion: Bool) {
    }
    
    func appModel(_ appModel: AppModelProtocol, didEndPlaying ad: AdData, withCompanion: Bool) {
    }
}

extension PodcastsViewController: PlayerViewControllerDelegate {
    
    func playerViewController(_ playerViewController: PlayerViewController, shouldDismiss animated: Bool) {
        /// dismiss the `PlayerViewController`
        playerViewController.dismiss(animated: animated) { [weak self] in
            if let indexPath = self?.tableView.indexPathForSelectedRow {
                self?.tableView.deselectRow(at: indexPath, animated: true)
            }
            if self?.model.isPlaying ?? false {
                /// show the minimized player
                self?.showMinimizedPlayer()
            }
        }
    }
}

extension PodcastsViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        if model.isPlaying {
            /// show and configure the minimized player
            showMinimizedPlayer()
        }
    }
}
