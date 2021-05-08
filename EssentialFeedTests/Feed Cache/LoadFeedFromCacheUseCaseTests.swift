//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Mayowa Olunuga on 16/04/2021.
//

import XCTest
import EssentialFeed


class LoadFeedFromCacheUseCaseTests : XCTestCase {
    func test_init_doesNotMessageUponCreation(){
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestCacheRetrieval() {
        let (sut, store) = makeSUT()
        
        sut.load{_ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError(){
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(retrievalError), when: {
            store.completeRetrieval(with : retrievalError)
        })
    }
    
    func test_load_deliversNoImagesOnEmptyCache(){
        let (sut, store) = makeSUT()
        let emptyImages = [FeedImage]()
        
        expect(sut, toCompleteWith: .success(emptyImages), when: {
            store.completeRetrievalWithAnEmptyCache()
        })
    }
    
    func test_load_deliversCachedImagesOnLessThanSevenDaysOldCache (){
        let fixedCurrentDate = Date()
        
        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})
        let feed = uniqueImageFeed()
        
        let lessThanSevenDaysOldTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds :  1)
        
        expect(sut, toCompleteWith: .success(feed.model), when: {
            store.completeRetrieval(with: feed.local, timeStamp : lessThanSevenDaysOldTimeStamp)
        })
    }
    
    func test_load_deliversNoImagesOnSevenDaysOldCache (){
        let fixedCurrentDate = Date()
        
        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})
        let feed = uniqueImageFeed()
        
        let lessThanSevenDaysOldTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge()
        
        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrieval(with: feed.local, timeStamp : lessThanSevenDaysOldTimeStamp)
        })
    }
    
    func test_load_deliversNoImagesOnMoreThanSevenDaysOldCache (){
        let fixedCurrentDate = Date()
        
        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})
        let feed = uniqueImageFeed()
        
        let moreThanSevenDaysOldTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        
        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrieval(with: feed.local, timeStamp : moreThanSevenDaysOldTimeStamp)
        })
    }
    
    
    func test_load_hasNoSideEffectOnRetrievalError(){
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
    
        sut.load{_ in }
        store.completeRetrieval(with : retrievalError)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnEmptyCache(){
        let (sut, store) = makeSUT()

        sut.load{_ in }
        store.completeRetrievalWithAnEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnNonExpiredCache(){
        let feed = uniqueImageFeed()
        let nonExpiredTimeStamp = Date().minusFeedCacheMaxAge().adding(seconds: 1)
        let fixedCurrentDate = Date()

        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})
       
        sut.load{_ in }
        store.completeRetrieval(with: feed.local, timeStamp: nonExpiredTimeStamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnCacheExpiration(){
        let feed = uniqueImageFeed()
        let onExpirationTimeStamp = Date().minusFeedCacheMaxAge()
        let fixedCurrentDate = Date()

        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})
       
        sut.load{_ in }
        store.completeRetrieval(with: feed.local, timeStamp: onExpirationTimeStamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnExpiredCache(){
        let feed = uniqueImageFeed()
        let expiredTimeStamp = Date().minusFeedCacheMaxAge().adding(seconds: -1)
        let fixedCurrentDate = Date()

        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})
       
        sut.load{_ in }
        store.completeRetrieval(with: feed.local, timeStamp: expiredTimeStamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_doestNotReturnResultWhenInstanceHasBeenDeallocated(){
        let store = FeedStoreSpy()
        var sut : LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedResults  = [FeedLoader.Result]()
        sut?.load { receivedResults.append($0) }
        
        sut = nil
        store.completeRetrievalWithAnEmptyCache()
        
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
    
    private func expect(_ sut : LocalFeedLoader, toCompleteWith expectedResult : FeedLoader.Result, when action : ()->Void, file : StaticString = #filePath, line : UInt = #line ){
        let exp = expectation(description: "Wait for load completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult ) {
            case let (.success(receivedImages), .success(expectedImages)):
                XCTAssertEqual(receivedImages, expectedImages, file : file, line : line)
            case let (.failure(receivedError as NSError) , .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file : file, line : line)
            default:
                XCTFail("Expected \(expectedResult) but got \(receivedResult) instead", file : file, line : line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }
}

