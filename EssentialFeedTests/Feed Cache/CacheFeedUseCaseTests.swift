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
      
        sut.save(uniqueItems().model){_ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError(){
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        sut.save(uniqueItems().model){_ in }
        store.completeDeletionWith(with: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    
    func test_save_requestsNewCacheInsertionWithTimeStampOnSuccessfulDeletion(){
        let timeStamp = Date()
        let items = uniqueItems()
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
        
        sut.save(uniqueItems().model){ error in
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
        sut?.save([uniqueItem()]){ receivedResults.append($0)}
        sut = nil
        store.completeDeletionWith(with: anyNSError())
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated(){
        let store = FeedStoreSpy()
        var sut : LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: {Date()})

        var receivedResults = [LocalFeedLoader.SaveResult]()
        sut?.save([uniqueItem()]){ receivedResults.append($0)}
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
        
        sut.save([uniqueItem()]){ error in
            receivedError = error
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?, expectedError)
    }
    
    private func uniqueItem()-> FeedItem {
        return FeedItem(id: UUID(), description: "any-description", location: "any-location", imageUrl: anyURL() )
    }
    
    private func uniqueItems()-> (model : [FeedItem], local : [LocalFeedItem]) {
        let models = [uniqueItem(), uniqueItem()]
        let locals = models.map{LocalFeedItem(id: $0.id, description: $0.description, location: $0.location, imageUrl: $0.imageURL)}
        return (models, locals)
    }
    
    private class FeedStoreSpy : FeedStore {
        private var deletionCompletions = [DeletionCompletion]()
        private var insertionCompletions = [DeletionCompletion]()
        
        
        enum ReceivedMessage : Equatable {
            case deleteCacheFeed
            case insert([LocalFeedItem], Date)
        }
        private(set) var receivedMessages = [ReceivedMessage]()
       
        
        func deleteCachedFeed(completion :@escaping DeletionCompletion){
            receivedMessages.append(.deleteCacheFeed)
            deletionCompletions.append(completion)
        }
        
        func insert(_ items : [LocalFeedItem], timeStamp : Date, completion : @escaping InsertionCompletion){
            receivedMessages.append(.insert(items, timeStamp))
            insertionCompletions.append(completion)
        }
        
        func completeDeletionWith(with error : NSError, at index : Int = 0){
            deletionCompletions[index](error)
        }
        
        func completeInsertionWith(with error : NSError, at index : Int = 0){
            insertionCompletions[index](error)
        }
        
        func completeDeletionSuccessfully(at index : Int = 0){
            deletionCompletions[index](nil)
        }
        
        func completeInsertionSuccessfully(at index:  Int = 0){
            insertionCompletions[index](nil)
        }
    }
    
    private func anyURL() -> URL {URL(string: "http://any-url.com")!}
    private func anyNSError()-> NSError {NSError(domain: "Any error", code: NSURLErrorUnknown, userInfo: ["":""])}
}
