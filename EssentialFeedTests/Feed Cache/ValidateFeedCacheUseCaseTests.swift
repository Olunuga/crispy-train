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
    
    func test_validateCache_doesNotDeleteCacheOnLessThanSevenDaysOldCache(){
        let feed = uniqueImageFeed()
        let lessThanSevenDaysTime = Date().adding(days: -7).adding(days: 1)
        let fixedCurrentDate = Date()

        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})
       
        sut.validateCache()
        store.completeRetrieval(with: feed.local, timeStamp: lessThanSevenDaysTime)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_deletesCacheOnSevenDaysOldCache(){
        let feed = uniqueImageFeed()
        let sevenDaysOldTimeStamp = Date().adding(days: -7)
        let fixedCurrentDate = Date()

        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})

        sut.validateCache()
        store.completeRetrieval(with: feed.local, timeStamp: sevenDaysOldTimeStamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve,.deleteCacheFeed])
    }
    
    
    func test_validateCache_deleteCacheOnMoreThanSevenDaysOldCache(){
        let feed = uniqueImageFeed()
        let moreThanSevenDaysOldTimeStamp = Date().adding(days: -7).adding(days: -1)
        let fixedCurrentDate = Date()

        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})

        sut.validateCache()
        store.completeRetrieval(with: feed.local, timeStamp: moreThanSevenDaysOldTimeStamp)

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


