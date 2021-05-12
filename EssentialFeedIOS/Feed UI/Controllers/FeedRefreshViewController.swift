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
        viewModel.isLoading = {[weak view] loading in
            if loading {
                view?.beginRefreshing()
            }else{
                view?.endRefreshing()
            }
        }
        
        view.addTarget(self, action: #selector(load), for: .valueChanged)
        return view
    }
}
