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

extension WeakRefVirtualProxy : FeedImageView where T : FeedImageView, T.Image == UIImage {
    func display(_ model: FeedImageViewData<UIImage>) {
        object?.display(model)
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
            let adapter  = FeedImageDataLoaderPresenterAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(feedImage: model, imageLoader: loader)
            let view = FeedImageCellController(delegate: adapter)
            
            adapter.feedImagePresenter = FeedImageViewPresenter(view: WeakRefVirtualProxy(view), imageTransformer: UIImage.init)
            return view
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


private final class FeedImageDataLoaderPresenterAdapter<View : FeedImageView, Image> : FeedImageCellControllerDelegate where View.Image == Image {
    
    private var model : FeedImage
    private var task : FeedImageDataLoaderTask?
    private var feedImageLoader : FeedImageDataLoader
    
    var feedImagePresenter : FeedImageViewPresenter<View, Image>?
    
    init(feedImage : FeedImage, imageLoader : FeedImageDataLoader) {
        self.model = feedImage
        self.feedImageLoader = imageLoader
    }
    
    func didCancelImageRequest() {
        task?.cancel()
    }
    
    func didRequestImage() {
        feedImagePresenter?.didStartLoadingImageData(for: model)
        
        let model = self.model
        task = feedImageLoader.loadImageData(from: model.url){[weak self] result in
            switch result {
            case let .success(data):
                self?.feedImagePresenter?.didFinishLoadingImageData(with: data, for: model)
            case let .failure(error):
                self?.feedImagePresenter?.didFinishLoadingData(with: error, for: model)
            }
        }
    }
}


