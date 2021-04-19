//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Mayowa Olunuga on 15/04/2021.
//
import XCTest
import EssentialFeed

class CacheFeedUseCaseTests : XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation(){
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestsCacheDeletion(){
        let(sut, store) = makeSUT()
      
        sut.save(uniqueImageFeed().model){_ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError(){
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        sut.save(uniqueImageFeed().model){_ in }
        store.completeDeletionWith(with: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    
    func test_save_requestsNewCacheInsertionWithTimeStampOnSuccessfulDeletion(){
        let timeStamp = Date()
        let items = uniqueImageFeed()
        let (sut, store) = makeSUT(currentDate : {timeStamp})
        
        sut.save(items.model){_ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed, .insert(items.local, timeStamp)])
    }
    
    
    func test_save_failsOnDeletionError(){
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWith: deletionError, when: {
            store.completeDeletionWith(with: deletionError)
        })
    }
    
    func test_save_failsOnInsertionError(){
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()
    
        expect(sut, toCompleteWith: insertionError, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertionWith(with: insertionError)
        })
    }
    
    func test_save_succeedsOnSuccessfulCacheInsertion(){
        let (sut, store) = makeSUT()
       
        let exp = expectation(description: "Wait for save")
        var receivedError : Error?
        
        sut.save(uniqueImageFeed().model){ error in
            receivedError = error
            exp.fulfill()
        }
        store.completeDeletionSuccessfully()
        store.completeInsertionSuccessfully()
        
        wait(for: [exp], timeout: 1.0)
       
        XCTAssertNil(receivedError)
    }
    
    
    func test_save_doesNotDeliverErrorWhenAfterSUTInstanceHasBeenDeallocated(){
        let store = FeedStoreSpy()
        var sut : LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: {Date()})

        var receivedResults = [LocalFeedLoader.SaveResult]()
        sut?.save([uniqueImage()]){ receivedResults.append($0)}
        sut = nil
        store.completeDeletionWith(with: anyNSError())
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated(){
        let store = FeedStoreSpy()
        var sut : LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: {Date()})

        var receivedResults = [LocalFeedLoader.SaveResult]()
        sut?.save([uniqueImage()]){ receivedResults.append($0)}
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertionWith(with: anyNSError())
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    //MARK: Helpers
    private func makeSUT(currentDate : @escaping ()->Date = Date.init, file: StaticString = #filePath, line: UInt = #line)-> (sut: LocalFeedLoader, store : FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate : currentDate)
        trackForMemoryLeak(sut, file: file, line:  line)
        trackForMemoryLeak(store, file: file, line: line)
        return (sut, store)
    }
    
    
   private func expect(_ sut : LocalFeedLoader, toCompleteWith expectedError : NSError?, when action : ()->(), file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for action")
        var receivedError : Error?
        
        sut.save([uniqueImage()]){ error in
            receivedError = error
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?, expectedError)
    }
    
    private func uniqueImage()-> FeedImage {
        return FeedImage(id: UUID(), description: "any-description", location: "any-location", url: anyURL() )
    }
    
    private func uniqueImageFeed()-> (model : [FeedImage], local : [LocalFeedImage]) {
        let models = [uniqueImage(), uniqueImage()]
        let locals = models.map{LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
        return (models, locals)
    }
    
    private func anyURL() -> URL {URL(string: "http://any-url.com")!}
    private func anyNSError()-> NSError {NSError(domain: "Any error", code: NSURLErrorUnknown, userInfo: ["":""])}
}
