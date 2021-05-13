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
    var feedView : FeedView?
    var loadingView : FeedLoadingView?
    
    func didStartLoadingFeed(){
        loadingView?.display(FeedLoadingViewData(isLoading : true))
    }
    
    func didFinishLoadingFeed(with feed : [FeedImage]){
        loadingView?.display(FeedLoadingViewData(isLoading : false))
        feedView?.display(FeedViewData(feed : feed))
    }
    
    func didFinishLoading(with error : Error){
        loadingView?.display(FeedLoadingViewData(isLoading : false))
    }
    
}
