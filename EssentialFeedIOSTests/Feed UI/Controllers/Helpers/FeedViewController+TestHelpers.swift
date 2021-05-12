//
//  FeedViewController+TestHelpers.swift
//  EssentialFeedIOSTests
//
//  Created by Mayowa Olunuga on 12/05/2021.
//

import UIKit
import  EssentialFeedIOS


extension FeedViewController {
    func simulateUserInitiatedFeedReload(){
        refreshControl?.simulatePullToRefresh()
    }
    
    func simulateFeedImageViewNotNearVisible(at row : Int){
        simulateFeedImageNearVisible(at: row)
        
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImageSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }
    
    func simulateFeedImageNearVisible(at row : Int){
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImageSection)
        ds?.tableView(tableView, prefetchRowsAt: [index])
    }
    
    func simulateFeedImageNotViewVisible(at row: Int){
        let view = simulateFeedImageViewVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImageSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
    }
    
    @discardableResult
    func simulateFeedImageViewVisible(at index : Int) -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }
    
    func isShowingIndicator() ->Bool {
        refreshControl?.isRefreshing == true
    }
    
    func numberOfRenderedFeedImageViews()-> Int {
        return tableView.numberOfRows(inSection: feedImageSection)
    }
    
    func feedImageView(at row : Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: feedImageSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    
    private var feedImageSection : Int {
        0
    }
    
   
}
