//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Mayowa Olunuga on 15/04/2021.
//
import XCTest
import EssentialFeed

class LocalFeedLoader{
    private let store : FeedStore
    private let currentDate : ()->Date
    
    init(store : FeedStore, currentDate : @escaping ()->Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items : [FeedItem], completion : @escaping (Error?)->Void){
        store.deleteCachedFeed{ [weak self] error in
            guard let self = self else {return }
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else{
                self.store.insert(items, timeStamp: self.currentDate()){[weak self] error in
                    guard self != nil else {return}
                    completion(error)
                }
            }
        }
    }
}

protocol FeedStore {
    typealias DeletionCompletion = (Error?)-> Void
    typealias InsertionCompletion = (Error?)-> Void
    
    func deleteCachedFeed(completion :@escaping DeletionCompletion)
    func insert(_ items : [FeedItem], timeStamp : Date, completion : @escaping InsertionCompletion)
}
    


class CacheFeedUseCaseTests : XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation(){
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestsCacheDeletion(){
        let(sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items){_ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError(){
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        let deletionError = anyNSError()
        
        sut.save(items){_ in }
        store.completeDeletionWith(with: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    
    func test_save_requestsNewCacheInsertionWithTimeStampOnSuccessfulDeletion(){
        let timeStamp = Date()
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT(currentDate : {timeStamp})
        
        sut.save(items){_ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed, .insert(items, timeStamp)])
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
        let items = [uniqueItem(), uniqueItem()]
       
        let exp = expectation(description: "Wait for save")
        var receivedError : Error?
        
        sut.save(items){ error in
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

        var receivedResults = [Error?]()
        sut?.save([uniqueItem()]){ receivedResults.append($0)}
        sut = nil
        store.completeDeletionWith(with: anyNSError())
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated(){
        let store = FeedStoreSpy()
        var sut : LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: {Date()})

        var receivedResults = [Error?]()
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
    
    private class FeedStoreSpy : FeedStore {
        private var deletionCompletions = [DeletionCompletion]()
        private var insertionCompletions = [DeletionCompletion]()
        
        
        enum ReceivedMessage : Equatable {
            case deleteCacheFeed
            case insert([FeedItem], Date)
        }
        private(set) var receivedMessages = [ReceivedMessage]()
       
        
        func deleteCachedFeed(completion :@escaping DeletionCompletion){
            receivedMessages.append(.deleteCacheFeed)
            deletionCompletions.append(completion)
        }
        
        func insert(_ items : [FeedItem], timeStamp : Date, completion : @escaping InsertionCompletion){
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
