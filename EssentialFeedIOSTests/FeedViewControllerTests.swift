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
    
    func test_feedImageView_cancelsLoadsImageURLWhenVisible(){
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1])
        XCTAssertEqual(loader.canceledImageURLS, [], "Expected no canceled image URL requests until views is not visible")
        
        sut.simulateFeedImageNotViewVisible(at : 0)
        XCTAssertEqual(loader.canceledImageURLS, [image0.url], "Expected first image URL request once first view becomes visible")
        
        sut.simulateFeedImageNotViewVisible(at: 1)
        XCTAssertEqual(loader.canceledImageURLS, [image0.url, image1.url], "Expected second image URL request once second view also becomes visible")
    }
    
    func test_feedImageViewLoadingIndicator_isVisibleWhileLoading(){
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage(), makeImage()])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
       
        XCTAssertEqual(view0?.isShowingLoadingIndicator, true, "Expected loading indicator for first view while loading")
        XCTAssertEqual(view1?.isShowingLoadingIndicator, true, "Expected loading indicator for second view while loading")
        
        
        loader.completeImageLoading(at : 0)
        XCTAssertEqual(view0?.isShowingLoadingIndicator, false, "Expected no loading indicator for first view once image loading completes successfully")
        XCTAssertEqual(view1?.isShowingLoadingIndicator, true, "Expected no loading indicator state change for second view once first image loading complete successfully")
       
        loader.completeImageLoadingWithError(at : 1)
        XCTAssertEqual(view0?.isShowingLoadingIndicator, false, "Expected no loading indicator state change for first view once second image loading completes successfully")
        XCTAssertEqual(view1?.isShowingLoadingIndicator, false, "Expected no loading indicator for second view once second image loading complete with error")
    }
    
    
    func test_feedImageView_rendersImageLoadedFromURL(){
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage(), makeImage()])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(view0?.renderedImage, .none, "Expected no image for first view while loading first image")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image for second view while loading second image")
        
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected image for first view once image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image state change for second view once first image loading complete successfully")
       
        
        let imageData1 = UIImage.make(withColor: .blue).pngData()!
        loader.completeImageLoading(with: imageData1, at: 1)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected no image state change for first view once second image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, imageData1, "Expected image for second view once second image loading complete successfully")
    }
    
    func test_feedImageRetryButton_isVisibleOnImageURLLoadError(){
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage(), makeImage()])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view while loading")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action for second view while loading")
        
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view once first loading completes successfully")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action state change for second view once first image loading complete successfully")
       
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action state change for first view once second image loading completes successfully")
        XCTAssertEqual(view1?.isShowingRetryAction, true, "Expected retry action for second view once second image loading complete with error")
    }
    
    func test_feedImageRetryButton_isVisibleOnInvalidImageData(){
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage(), makeImage()])
        
        let view = sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(view?.isShowingRetryAction, false, "Expected no retry action while loading image")
        
        let invalidImageData = Data("invalid image".utf8)
        loader.completeImageLoading(with: invalidImageData, at: 0)
        XCTAssertEqual(view?.isShowingRetryAction, true, "Expected retry action once loading completes with invalid data")
        
    }
    
    func test_feedImageViewRetryAction_retriesImageLoad(){
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLS, [image0.url, image1.url], "Expected two image url requests for the two visible views")
        
        loader.completeImageLoadingWithError(at: 0)
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(loader.loadedImageURLS, [image0.url, image1.url], "Expected only two image URL requests before retry action")
        
        view0?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLS, [image0.url, image1.url, image0.url], "Expected third image url requests after first retry action")
        
        view1?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLS, [image0.url, image1.url, image0.url, image1.url], "Expected fourth image url requests after first retry action")
    }
    
    func test_feedImageView_preloadsImageURLWhenNearVisible(){
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1])
        XCTAssertEqual(loader.loadedImageURLS, [], "Expected no image url request until image is near visible")
        
        sut.simulateFeedImageNearVisible(at : 0)
        XCTAssertEqual(loader.loadedImageURLS, [image0.url], "Expected first image URL request once first image is near visible")
        
        sut.simulateFeedImageNearVisible(at : 1)
        XCTAssertEqual(loader.loadedImageURLS, [image0.url, image1.url], "Expected second image URL request once second image is near visible")
    }
    
    func test_feedImageView_cancelsImageURLPreloadingWhenNearVisible(){
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1])
        XCTAssertEqual(loader.canceledImageURLS, [], "Expected no canceled image url request until image is near visible")
        
        sut.simulateFeedImageViewNotNearVisible(at : 0)
        XCTAssertEqual(loader.canceledImageURLS, [image0.url], "Expected first canceled image URL request once first image is not near visible")
        
        sut.simulateFeedImageViewNotNearVisible(at : 1)
        XCTAssertEqual(loader.canceledImageURLS, [image0.url, image1.url], "Expected second canceled image URL request once second image is not near visible")
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
        
        var loadedImageURLS : [URL] {
             return imageRequests.map{$0.url}
        }
        
        private(set) var canceledImageURLS = [URL]()
        
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
        private struct TaskSpy : FeedImageDataLoaderTask {
            let cancelCallback : ()->Void
            
            func cancel(){
                cancelCallback()
            }
        }
        
        private var imageRequests = [(url : URL, completion :(FeedImageDataLoader.Result) -> Void )]()
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            imageRequests.append((url, completion))
            return TaskSpy{[weak self] in  self?.canceledImageURLS.append(url)}
        }
        
        func completeImageLoading(with imageData : Data = Data(), at index : Int = 0){
            imageRequests[index].completion(.success(imageData))
        }
        
        func completeImageLoadingWithError(at index: Int){
            let error = NSError(domain: "an error", code: 0)
            imageRequests[index].completion(.failure(error))
        }
        
    }
}


private extension FeedViewController {
    func simulateUserInitiatedFeedReload(){
        refreshControl?.simulatePullToRefresh()
    }
    
    func simulateFeedImageViewNotNearVisible(at row : Int){
        simulateFeedImageViewVisible(at: row)
        
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

private extension UIRefreshControl {
    func simulatePullToRefresh(){
        allTargets.forEach{ target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach{
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

private extension UIButton {
    func simulateTap(){
        allTargets.forEach{ target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach{
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}


private extension FeedImageCell {
    var isShowingLocation : Bool {
        return !locationContainer.isHidden
    }
    
    var isShowingRetryAction : Bool {
        return !feedImageRetryButton.isHidden
    }
    
    var locationText : String? {
        return locationLabel.text
    }
    
    var descriptionText : String? {
        return descriptionLabel.text
    }
    
    var isShowingLoadingIndicator : Bool {
        return feedImageContainer.isShimmering
    }
    
    var renderedImage : Data? {
       return feedImageView.image?.pngData()
    }
    
    func simulateRetryAction(){
        feedImageRetryButton.simulateTap()
    }
}


private extension UIImage {
    static func make(withColor color : UIColor) -> UIImage {
        let rect = CGRect(x:0, y:0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndPDFContext()
        return img!
    }
}
