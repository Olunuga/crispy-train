//
//  FeedViewControllerTests.swift
//  EssentialFeed
//
//  Created by Mayowa Olunuga on 10/05/2021.
//

import XCTest
import UIKit
import EssentialFeed
import EssentialFeedIOS



final class FeedViewControllerTests : XCTestCase {
    
    func test_loadFeedActions_requestFeedFromLoader(){
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadFeedCallCount, 0, "Expected no loading requests before view is loaded")
    
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected a loading request once a view is loaded")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 2, "Expected another loading request once user initiates another load")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 3, "Expected a third loading request once user initiates another load")
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed(){
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingIndicator(), "Expected loading indicator once view is loaded")
        
        loader.completeFeedLoading(at : 0)
        XCTAssertFalse(sut.isShowingIndicator(), "Expected no loading indicator once loading completes successfully")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingIndicator(), "Expected loading indicator once user initiates reload")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingIndicator(), "Expected loading indicator once user initiates reload")
        
        loader.completeFeedLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingIndicator(), "Expected no loading indicator once user initiated reload completes with error")
        
    }
    
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed(){
        let image0 = makeImage(description : "a description", location : "a location")
        let image1 = makeImage(description : nil, location : "another location")
        let image2 = makeImage(description : "another description", location : nil)
        let image3 = makeImage(description : nil, location : nil)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        
        loader.completeFeedLoading(with : [image0], at : 0)
        XCTAssertEqual(sut.numberOfRenderedFeedImageViews(), 1)
        assertThat(sut, isRendering: [image0])

        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(with: [image0, image1, image2, image3], at: 1)
        XCTAssertEqual(sut.numberOfRenderedFeedImageViews(), 4)
        assertThat(sut, isRendering:  [image0, image1, image2, image3])
    }
    
    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError(){
        let image = makeImage()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image], at: 0)
        assertThat(sut, isRendering: [image])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoadingWithError(at : 1)
        assertThat(sut, isRendering: [image])
    }
    
    
    func test_feedImageView_loadsImageURLWhenVisible(){
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1])
        
        XCTAssertEqual(loader.loadedImageURLS, [], "Expected no image URL requests until views become visible")
        sut.simulateFeedImageViewVisible(at : 0)
        XCTAssertEqual(loader.loadedImageURLS, [image0.url], "Expected first image URL request once first view becomes visible")
        
        sut.simulateFeedImageViewVisible(at : 1)
        XCTAssertEqual(loader.loadedImageURLS, [image0.url, image1.url], "Expected second image URL request once second view also becomes visible")
    }
    
    
    //MARK: - Helpers
    
    private func makeSUT(file : StaticString = #filePath, line : UInt = #line) -> (sut : FeedViewController, loader : LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(feedLoader : loader, imageLoader: loader)
        trackForMemoryLeak(loader, file : file, line : line)
        trackForMemoryLeak(sut, file : file, line : line)
        return (sut,loader)
    }
    
    private func makeImage(description : String? = nil, location : String? = nil, url : URL = URL(string: "http://any-url.com")!)-> FeedImage {
        return FeedImage(id: UUID(), description: description, location: location, url: url)
    }
    
    
    private func assertThat(_ sut : FeedViewController, isRendering feed : [FeedImage], file : StaticString = #filePath, line : UInt = #line){
        guard sut.numberOfRenderedFeedImageViews() == feed.count else {
            return XCTFail("Expected \(feed.count) images, got \(sut.numberOfRenderedFeedImageViews()) instead", file: file, line: line)
        }
        
        feed.enumerated().forEach{ index, image in
            assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
        }
    }
    
    private func assertThat(_ sut : FeedViewController, hasViewConfiguredFor image : FeedImage, at index : Int,file : StaticString = #filePath, line : UInt = #line ) {
        let view = sut.feedImageView(at : index)
        
        guard let cell = view as? FeedImageCell else {
            return XCTFail("Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        
        let shouldLocationBeVisible = (image.location != nil)
        XCTAssertEqual(cell.isShowingLocation, shouldLocationBeVisible, "Expected `isShowingLocation` to be \(shouldLocationBeVisible) for image view at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.locationText, image.location, "Expected description text to be  \(String(describing: image.location)) for image view at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.descriptionText, image.description, "Expected description text to be  \(String(describing: image.description)) for image view at index (\(index))", file: file, line: line)
    }
    
    class LoaderSpy  : FeedLoader, FeedImageDataLoader {
       
        //MARK: FeedLoader
        var feedRequests = [(FeedLoader.Result) -> Void]()
        
        var loadFeedCallCount : Int {
            return feedRequests.count
        }
        
        private(set) var loadedImageURLS =  [URL]()
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            feedRequests.append(completion)
        }
        
        func completeFeedLoading(with feed : [FeedImage] = [], at index : Int = 0){
            feedRequests[index](.success(feed))
        }
        
        func completeFeedLoadingWithError(at index : Int){
            let error = NSError(domain: "an error", code: 0)
            feedRequests[index](.failure(error))
        }
        
        
        //MARK: FeedImageDataLoader
        func loadImageData(from url: URL) {
            loadedImageURLS.append(url)
        }
    }
}


private extension FeedViewController {
    func simulateUserInitiatedFeedReload(){
        refreshControl?.simulatePullToRefresh()
    }
    
    func simulateFeedImageViewVisible(at index : Int){
        _ = feedImageView(at: index)
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

private extension UIRefreshControl {
    func simulatePullToRefresh(){
        allTargets.forEach{ target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach{
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}


private extension FeedImageCell {
    var isShowingLocation : Bool {
        return !locationContainer.isHidden
    }
    
    var locationText : String? {
        return locationLabel.text
    }
    
    var descriptionText : String? {
        return descriptionLabel.text
    }
}
