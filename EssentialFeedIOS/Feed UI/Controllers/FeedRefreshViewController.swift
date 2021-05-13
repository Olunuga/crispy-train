//
//  FeedRefreshViewController.swift
//  EssentialFeedIOS
//
//  Created by Mayowa Olunuga on 12/05/2021.
//

import UIKit

final class FeedRefreshViewController : NSObject, FeedLoadingView  {
    private(set) lazy var view = loadView()
    
    private var loadFeed : ()->Void
    
    init(loadFeed: @escaping ()->Void) {
        self.loadFeed = loadFeed
    }
    
    @objc func load(){
        loadFeed()
    }
    
    func display(_ viewModel: FeedLoadingViewData) {
        if viewModel.isLoading {
            view.beginRefreshing()
        }else{
            view.endRefreshing()
        }
    }
    
    private func loadView() -> UIRefreshControl{
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(load), for: .valueChanged)
        return view
    }
}
