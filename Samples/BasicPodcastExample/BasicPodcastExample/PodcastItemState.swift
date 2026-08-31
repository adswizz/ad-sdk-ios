//
//  PodcastItemState.swift
//  BasicPodcastExample
//
//  Created by George Mihoc on 19.01.2026.
//

import SwiftUI

struct PodcastItemState {
    let id: Int
    let title: String
    let filename: String
    var downloadProgress: Float = 0
    var isDownloading: Bool = false
    var isDownloaded: Bool = false
}
