//
//  FeedViewModel.swift
//  EssentialFeedIOS
//
//  Created by Mayowa Olunuga on 12/05/2021.
//

import EssentialFeed

final class FeedViewModel {
    private var feedLoader : FeedLoader
    
    init(feedLoader : FeedLoader) {
        self.feedLoader = feedLoader
    }
    

    private(set) var isLoading : Bool = false {
        didSet {
            onChange?(self)
        }
    }
    
    var onFeedLoad : (([FeedImage])->Void)?
    var onChange : ((FeedViewModel)->Void)?
    
    func loadFeed(){
        isLoading = true
        feedLoader.load {[weak self]  result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.isLoading = false
        }
    }
}
