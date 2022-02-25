//
//  URL+Extensions.swift
//  BasicPodcastExample
//
//  Created by Adrian Manolache on 14.02.2022.
//

import Foundation

extension URL {
    func getPathForPodcast() -> URL {
        let lastPath = lastPathComponent
        let paths = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
        let baseLocation = URL(fileURLWithPath: paths.first ?? NSTemporaryDirectory())
        let location = baseLocation.appendingPathComponent("BasicPodcastExamplePodcasts", isDirectory: true)
        if !FileManager.default.fileExists(atPath: location.path) {
            do {
                try FileManager.default.createDirectory(at: location, withIntermediateDirectories: false, attributes: nil)
            } catch {
                print("getPath \(error)")
            }
        }
        let fileLocation = location.appendingPathComponent(lastPath)
        return fileLocation
    }
}
