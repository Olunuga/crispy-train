//
//  FeedRefreshViewController.swift
//  EssentialFeedIOS
//
//  Created by Mayowa Olunuga on 12/05/2021.
//

import EssentialFeed
import UIKit

final class FeedRefreshViewController : NSObject  {
    private var feedLoader : FeedLoader
    
    init(feedLoader : FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    private(set) lazy var view : UIRefreshControl = {
        var view = UIRefreshControl()
        view.addTarget(self, action: #selector(load), for: .valueChanged)
        return view
    }()
    
    var onRefresh : (([FeedImage])->Void)?
    
    @objc func load(){
        view.beginRefreshing()
        feedLoader.load {[weak self]  result in
            if let feed = try? result.get() {
                self?.onRefresh?(feed)
            }
            self?.view.endRefreshing()
        }
    }
}
