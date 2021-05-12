//
//  FeedRefreshViewController.swift
//  EssentialFeedIOS
//
//  Created by Mayowa Olunuga on 12/05/2021.
//

import UIKit

final class FeedRefreshViewController : NSObject  {
    private var viewModel : FeedViewModel
    private(set) lazy var view = bounded(UIRefreshControl())
    
    init(viewModel : FeedViewModel) {
        self.viewModel = viewModel
    }
    
    @objc func load(){
        viewModel.loadFeed()
    }
    
    private func bounded(_ view : UIRefreshControl) -> UIRefreshControl{
        viewModel.onChange = {[weak self] viewModel in
            if  viewModel.isLoading {
                self?.view.beginRefreshing()
            }else{
                self?.view.endRefreshing()
            }
        }
        view.addTarget(self, action: #selector(load), for: .valueChanged)
        return view
    }
}
