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
    
    func save(_ items : [FeedItem]){
        store.deleteCachedFeed{ [unowned self] error in
            if error == nil {
                self.store.insert(items, timeStamp: self.currentDate())
            }
        }
    }
}
      
class FeedStore {
    typealias DeletionCompletion = (Error?)-> Void
    private var deletionCompletions = [DeletionCompletion]()
    
    
    enum ReceivedMessage : Equatable {
        case deleteCacheFeed
        case insert([FeedItem], Date)
    }
    private(set) var receivedMessages = [ReceivedMessage]()
   
    
    func deleteCachedFeed(completion :@escaping (Error?)->Void){
        receivedMessages.append(.deleteCacheFeed)
        deletionCompletions.append(completion)
    }
    
    func insert(_ items : [FeedItem], timeStamp : Date){
        receivedMessages.append(.insert(items, timeStamp))
    }
    
    func completeDeletionWith(with error : NSError, at index : Int = 0){
        deletionCompletions[index](error)
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
        sut.save(items)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError(){
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        let deletionError = anyNSError()
        
        sut.save(items)
        store.completeDeletionWith(with: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    
    func test_save_requestsNewCacheInsertionWithTimeStampOnSuccessfulDeletion(){
        let timeStamp = Date()
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT(currentDate : {timeStamp})
        
        sut.save(items)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed, .insert(items, timeStamp)])
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
