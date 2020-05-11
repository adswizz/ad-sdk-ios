//
//  WatchSupport.swift
//  BasicAdRequestExample
//
//  Created by Teodor Cristea on 05/03/2020.
//  Copyright © 2020 Inc, AdsWizz. All rights reserved.
//

import Foundation

enum State: String, Codable {
    case playingAds
    case playingContent
}

protocol WatchSupport {
    var hasSupport: Bool { get }
    func sendMessage(_ state: State)
}
