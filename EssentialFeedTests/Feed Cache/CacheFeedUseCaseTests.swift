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
        store.deleteCachedFeed{ [unowned self] error in
            if error == nil {
                self.store.insert(items, timeStamp: self.currentDate(), completion: completion)
            }else{
              completion(error)
            }
        }
    }
}
      
class FeedStore {
    typealias DeletionCompletion = (Error?)-> Void
    typealias InsertionCompletion = (Error?)-> Void
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
        let items = [uniqueItem(), uniqueItem()]
        let deletionError = anyNSError()
        
        
        let exp = expectation(description: "Wait for completion")
        var receivedError : Error?
        
        sut.save(items){ error in
            receivedError = error
            exp.fulfill()
        }
        store.completeDeletionWith(with: deletionError)
        
        wait(for: [exp], timeout: 1.0)
       
        XCTAssertEqual(receivedError as NSError?, deletionError)
    }
    
    func test_save_failsOnInsertionError(){
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        let insertionError = anyNSError()
        
        
        let exp = expectation(description: "Wait for save")
        var receivedError : Error?
        
        sut.save(items){ error in
            receivedError = error
            exp.fulfill()
        }
        store.completeDeletionSuccessfully()
        store.completeInsertionWith(with: insertionError)
        
        wait(for: [exp], timeout: 1.0)
       
        XCTAssertEqual(receivedError as NSError?, insertionError)
    }
    
    //MARK: Helpers
    func makeSUT(currentDate : @escaping ()->Date = Date.init, file: StaticString = #filePath, line: UInt = #line)-> (sut: LocalFeedLoader, store : FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate : currentDate)
        trackForMemoryLeak(sut, file: file, line:  line)
        trackForMemoryLeak(store, file: file, line: line)
        return (sut, store)
    }
    
    private func uniqueItem()-> FeedItem {
        return FeedItem(id: UUID(), description: "any-description", location: "any-location", imageUrl: anyURL() )
    }
    
    private func anyURL() -> URL {URL(string: "http://any-url.com")!}
    private func anyNSError()-> NSError {NSError(domain: "Any error", code: NSURLErrorUnknown, userInfo: ["":""])}
}
