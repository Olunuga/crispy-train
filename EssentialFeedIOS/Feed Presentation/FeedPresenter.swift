//
//  FeedPresenter.swift
//  EssentialFeedIOS
//
//  Created by Mayowa Olunuga on 13/05/2021.
//

import Foundation
import EssentialFeed


protocol FeedLoadingView {
    func display(_ viewModel : FeedLoadingViewData)
}

struct FeedLoadingViewData {
    let isLoading : Bool
}


protocol FeedView {
    func display(_ viewModel : FeedViewData)
}

struct FeedViewData {
    let feed : [FeedImage]
}



final class FeedPresenter {
    private var feedLoader : FeedLoader
    
    var feedView : FeedView?
    var loadingView : FeedLoadingView?
    
    init(feedLoader : FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func loadFeed(){
        loadingView?.display(FeedLoadingViewData(isLoading : true))
        feedLoader.load {[weak self]  result in
            if let feed = try? result.get() {
                self?.feedView?.display(FeedViewData(feed : feed))
            }
            self?.loadingView?.display(FeedLoadingViewData(isLoading : false))
        }
    }
}
