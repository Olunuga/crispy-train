//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Mayowa Olunuga on 17/04/2021.
//

import XCTest
import EssentialFeed

class ValidateFeedCacheUseCaseTests : XCTestCase {
    func test_init_doesNotMessageUponCreation(){
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_validateCache_deletesCacheOnRetrievalError(){
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
    
        sut.validateCache()
        store.completeRetrieval(with : retrievalError)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCacheFeed])
    }
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache(){
        let (sut, store) = makeSUT()

        sut.validateCache()
        store.completeRetrievalWithAnEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_doesNotDeleteCacheOnNonExpiredCache(){
        let feed = uniqueImageFeed()
        let nonExpiredTimeStamp = Date().minusFeedCacheMaxAge().adding(seconds: 1)
        let fixedCurrentDate = Date()

        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})
       
        sut.validateCache()
        store.completeRetrieval(with: feed.local, timeStamp: nonExpiredTimeStamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_deletesCacheOnExpiration(){
        let feed = uniqueImageFeed()
        let expiredTimeStamp = Date().minusFeedCacheMaxAge()
        let fixedCurrentDate = Date()

        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})

        sut.validateCache()
        store.completeRetrieval(with: feed.local, timeStamp: expiredTimeStamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve,.deleteCacheFeed])
    }
    
    
    func test_validateCache_deleteCacheOnExpiredCache(){
        let feed = uniqueImageFeed()
        let expiredTimeStamp = Date().minusFeedCacheMaxAge().adding(seconds: -1)
        let fixedCurrentDate = Date()

        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})

        sut.validateCache()
        store.completeRetrieval(with: feed.local, timeStamp: expiredTimeStamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve,.deleteCacheFeed])
    }
    
    
    func test_validateCache_doesDeleteInvalidCacheAfterSutInstanceHasBeenDeallocated(){
        let store = FeedStoreSpy()
        var sut : LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        sut?.validateCache()
        sut = nil
        store.completeRetrieval(with: anyNSError())
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    
    //MARK: Helper
    public func makeSUT(currentDate : @escaping ()->Date = Date.init, file: StaticString = #filePath, line: UInt = #line)-> (sut: LocalFeedLoader, store : FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate : currentDate)
        trackForMemoryLeak(sut, file: file, line:  line)
        trackForMemoryLeak(store, file: file, line: line)
        return (sut, store)
    }

}



