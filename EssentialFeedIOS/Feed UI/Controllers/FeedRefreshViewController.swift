//
//  FeedRefreshViewController.swift
//  EssentialFeedIOS
//
//  Created by Mayowa Olunuga on 12/05/2021.
//

import UIKit

protocol FeedRefreshViewControllerDelegate {
   func didRequestFeedRefresh()
}


final class FeedRefreshViewController : NSObject, FeedLoadingView  {
    private(set) lazy var view = loadView()
    
    private var delegate : FeedRefreshViewControllerDelegate
    
    init(delegate: FeedRefreshViewControllerDelegate ) {
        self.delegate = delegate
    }
    
    @objc func load(){
        delegate.didRequestFeedRefresh()
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
