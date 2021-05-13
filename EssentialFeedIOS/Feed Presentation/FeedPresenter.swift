//
//  FeedPresenter.swift
//  EssentialFeedIOS
//
//  Created by Mayowa Olunuga on 13/05/2021.
//

import Foundation
import EssentialFeed


protocol FeedView {
    func display(feed : [FeedImage])
}

protocol FeedLoadingView : class {
    func display(isLoading : Bool)
}

final class FeedPresenter {
    private var feedLoader : FeedLoader
    
    var feedView : FeedView?
    weak var loadingView : FeedLoadingView?
    
    init(feedLoader : FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func loadFeed(){
        loadingView?.display(isLoading: true)
        feedLoader.load {[weak self]  result in
            if let feed = try? result.get() {
                self?.feedView?.display(feed: feed)
            }
            self?.loadingView?.display(isLoading: false)
        }
    }
}
