//
//  FeedLoader.swift
//  EssentialFeeds
//
//  Created by Mayowa Olunuga on 29/03/2021.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedImage], Error>

public protocol FeedLoader {
    func load(completion :@escaping (LoadFeedResult)->Void)
}
