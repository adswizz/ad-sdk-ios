//
//  Podcast.swift
//  AdvancedPodcastExample
//
//  Created by Teodor Cristea on 31.08.2023.
//  Copyright © 2023 Adswizz. All rights reserved.
//

import Foundation

struct PodcastConfig: Codable, Equatable {
    struct Podcast: Codable, Equatable {
        let id: String
        let title: String
        let author: String
        let url: String
        
        enum CodingKeys: String, CodingKey {
            case id
            case title
            case author
            case url
        }
        
        init() {
            id = UUID().uuidString
            title = ""
            author = ""
            url = ""
        }
        init(from decoder: Decoder) throws {
            let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
            id = try keyedContainer.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
            title = try keyedContainer.decodeIfPresent(String.self, forKey: .title) ?? ""
            author = try keyedContainer.decodeIfPresent(String.self, forKey: .author) ?? ""
            url = try keyedContainer.decodeIfPresent(String.self, forKey: .url) ?? ""
        }
        
        func encode(to encoder: Encoder) throws {
            var keyedContainer = encoder.container(keyedBy: CodingKeys.self)
            try keyedContainer.encode(id, forKey: .id)
            try keyedContainer.encode(title, forKey: .title)
            try keyedContainer.encode(author, forKey: .author)
            try keyedContainer.encode(url, forKey: .url)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case podcasts
    }
    
    let podcasts: [Podcast]

    init() {
        podcasts = [Podcast]()
    }
    
    init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        podcasts = try keyedContainer.decodeIfPresent([Podcast].self, forKey: .podcasts) ?? [Podcast]()
    }
    
    func encode(to encoder: Encoder) throws {
        var keyedContainer = encoder.container(keyedBy: CodingKeys.self)
        try keyedContainer.encode(podcasts, forKey: .podcasts)
    }
}

extension PodcastConfig.Podcast {
    func matches(podcast: PodcastConfig.Podcast) -> Bool {
        return self == podcast
    }
}
