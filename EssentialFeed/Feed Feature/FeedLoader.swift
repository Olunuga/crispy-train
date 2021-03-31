//
//  FeedLoader.swift
//  EssentialFeeds
//
//  Created by Mayowa Olunuga on 29/03/2021.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}


protocol FeedLoader {
    associatedtype Error : Swift.Error
    func load(completion :@escaping (LoadFeedResult)->Void)
}
