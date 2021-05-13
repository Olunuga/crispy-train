//
//  FeedUIComposer.swift
//  EssentialFeedIOS
//
//  Created by Mayowa Olunuga on 12/05/2021.
//

import UIKit
import EssentialFeed

public final class FeedUIComposer{
    
    private init(){}
    
    public static func feedComposedWith(feedLoader : FeedLoader, imageLoader : FeedImageDataLoader) -> FeedViewController {
        let presenter = FeedPresenter(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(loadFeed : presenter.loadFeed)
        let feedController = FeedViewController(refreshController: refreshController)
        presenter.loadingView = WeakRefVirtualProxy(refreshController)
        presenter.feedView = FeedPresenterAdapter(controller: feedController, loader: imageLoader)
        return feedController
    }
    
    private static func adaptFeedToCellControllers(forwardingTo controller : FeedViewController, loader : FeedImageDataLoader)->([FeedImage])->Void {
        return  {[weak controller] feed in
            controller?.tableModel = feed.map { model in
                let feedImageViewModel = FeedImageViewModel(model: model, imageLoader: loader, imageTransformer: UIImage.init)
                return FeedImageCellController(viewModel: feedImageViewModel)
                
            }
        }
        
    }
}

private final class WeakRefVirtualProxy<T : AnyObject> {
    private weak var object : T?
    init(_ object : T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy : FeedLoadingView where T : FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewData) {
        object?.display(viewModel)
    }
}


class FeedPresenterAdapter : FeedView {
    private weak var controller : FeedViewController?
    private let loader : FeedImageDataLoader
    
    init(controller : FeedViewController, loader : FeedImageDataLoader) {
        self.controller = controller
        self.loader = loader
    }
    
    func display(_ viewModel: FeedViewData) {
        controller?.tableModel = viewModel.feed.map { model in
            let feedImageViewModel = FeedImageViewModel(model: model, imageLoader: loader, imageTransformer: UIImage.init)
            return FeedImageCellController(viewModel: feedImageViewModel)
            
        }
    }
}
