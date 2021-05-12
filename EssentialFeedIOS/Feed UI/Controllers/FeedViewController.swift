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
    var tableModel = [FeedImageCellController]() {
        didSet {tableView.reloadData()}
    }
    
    convenience init(refreshController : FeedRefreshViewController) {
        self.init()
        self.refreshController = refreshController
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = refreshController?.view
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
        cancelCellControllerLoad(rowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach{ indexPath in
        cellController(forRowAt: indexPath).preLoad()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoad)
    }
    
    func cellController(forRowAt indexPath : IndexPath) -> FeedImageCellController {
        return tableModel[indexPath.row]
    }
    
    func cancelCellControllerLoad(rowAt indexPath : IndexPath){
        cellController(forRowAt: indexPath).cancelLoad()
    }
}
