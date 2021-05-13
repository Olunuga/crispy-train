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
        let presenterAdapter = FeedLoaderPresenterAdapter(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(delegate: presenterAdapter)
        let feedController = FeedViewController(refreshController: refreshController)
        let presenter = FeedPresenter(feedView: FeedViewImageLoaderAdapter(feedViewController: feedController, loader: imageLoader), loadingView: WeakRefVirtualProxy(refreshController))
        presenterAdapter.feedPresenter = presenter
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


private final class FeedViewImageLoaderAdapter : FeedView {
    private weak var feedViewController : FeedViewController?
    private let loader : FeedImageDataLoader
    
    init(feedViewController : FeedViewController, loader : FeedImageDataLoader) {
        self.feedViewController = feedViewController
        self.loader = loader
    }
    
    func display(_ viewModel: FeedViewData) {
        feedViewController?.tableModel = viewModel.feed.map { model in
            let feedImageViewModel = FeedImageViewModel(model: model, imageLoader: loader, imageTransformer: UIImage.init)
            return FeedImageCellController(viewModel: feedImageViewModel)
            
        }
    }
}


private final class FeedLoaderPresenterAdapter : FeedRefreshViewControllerDelegate {
    var feedPresenter : FeedPresenter?
    private let feedLoader : FeedLoader
    
    init(feedLoader : FeedLoader) {
        self.feedLoader = feedLoader
    }

    func didRequestFeedRefresh() {
        feedPresenter?.didStartLoadingFeed()
        feedLoader.load{[weak self]  result in
            switch result {
            case let .success(feed):
                self?.feedPresenter?.didFinishLoadingFeed(with: feed)
            case let .failure(error):
                self?.feedPresenter?.didFinishLoading(with: error)
            }
        }
    }
    
}


