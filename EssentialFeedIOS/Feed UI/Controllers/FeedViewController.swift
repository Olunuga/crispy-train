//
//  FeedViewController.swift
//  EssentialFeedIOS
//
//  Created by Mayowa Olunuga on 10/05/2021.
//

import UIKit
import EssentialFeed

public final class FeedViewController : UITableViewController, UITableViewDataSourcePrefetching {
    private var refreshController : FeedRefreshViewController?
    private var imageLoader : FeedImageDataLoader?
    private var tableModel = [FeedImage]() {
        didSet {tableView.reloadData()}
    }
    private var cellControllers = [IndexPath: FeedImageCellController]()
    
    public convenience init(feedLoader : FeedLoader, imageLoader : FeedImageDataLoader) {
        self.init()
        self.refreshController = FeedRefreshViewController(feedLoader: feedLoader)
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = refreshController?.view
        refreshController?.onRefresh = {[weak self] feed in
            self?.tableModel = feed
            
        }
        tableView.prefetchDataSource = self
        refreshController?.load()
    }
    
    
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(forRowAt: indexPath).view()
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        removeCellController(rowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach{ indexPath in
        cellController(forRowAt: indexPath).preLoad()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(removeCellController)
    }
    
    func cellController(forRowAt indexPath : IndexPath) -> FeedImageCellController {
        let cellModel = tableModel[indexPath.row]
        let cellController = FeedImageCellController(model: cellModel, imageLoader: imageLoader!)
        cellControllers[indexPath] = cellController
        return cellController
    }
    
    func removeCellController(rowAt indexPath : IndexPath){
        cellControllers[indexPath] = nil
    }
}
