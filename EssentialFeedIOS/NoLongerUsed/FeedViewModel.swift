//
//  FeedViewModel.swift
//  EssentialFeedIOS
//
//  Created by Mayowa Olunuga on 12/05/2021.
//

import EssentialFeed

private final class FeedViewModel {
    typealias Observable<T> = (T)->Void
    private var feedLoader : FeedLoader
    
    init(feedLoader : FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onFeedLoad : Observable<[FeedImage]>?
    var isLoading : Observable<Bool>?
    
    func loadFeed(){
        isLoading?(true)
        feedLoader.load {[weak self]  result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.isLoading?(false)
        }
    }
}
