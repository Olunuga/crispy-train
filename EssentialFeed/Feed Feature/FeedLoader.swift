//
//  FeedLoader.swift
//  EssentialFeeds
//
//  Created by Mayowa Olunuga on 29/03/2021.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
    
}
protocol FeedLoader {
    func load(completion :@escaping (LoadFeedResult)->Void)
}
