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
    var deleteCacheFeedCallCount = 0
    var insertCallCount = 0
    var insertions = [(items : [FeedItem], timeStamp : Date)]()
    
    private var deletionCompletions = [DeletionCompletion]()
   
    
    func deleteCachedFeed(completion :@escaping (Error?)->Void){
        deleteCacheFeedCallCount += 1
        deletionCompletions.append(completion)
    }
    
    func insert(_ items : [FeedItem], timeStamp : Date){
        insertCallCount += 1
        insertions.append((items, timeStamp))
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
        
        XCTAssertEqual(store.deleteCacheFeedCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion(){
        let(sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        
        XCTAssertEqual(store.deleteCacheFeedCallCount, 1)
    }
    
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError(){
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        let deletionError = anyNSError()
        
        sut.save(items)
        store.completeDeletionWith(with: deletionError)
        
        XCTAssertEqual(store.insertCallCount, 0)
    }
    
    func test_save_requestsNewCacheInsertOnSuccessfulDeletion(){
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.insertCallCount, 1)
    }
    
    func test_save_requestsNewCacheInsertionWithTimeStampOnSuccessfulDeletion(){
        let timeStamp = Date()
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT(currentDate : {timeStamp})
        
        sut.save(items)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.insertCallCount, 1)
        XCTAssertEqual(store.insertions.first?.items, items)
        XCTAssertEqual(store.insertions.first?.timeStamp, timeStamp)
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
