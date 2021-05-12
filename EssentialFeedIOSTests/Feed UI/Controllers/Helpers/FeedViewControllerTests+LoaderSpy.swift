//
//  FeedViewControllerTetst+LoaderSpy.swift
//  EssentialFeedIOSTests
//
//  Created by Mayowa Olunuga on 12/05/2021.
//

import EssentialFeed
import EssentialFeedIOS


extension FeedViewControllerTests {
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
