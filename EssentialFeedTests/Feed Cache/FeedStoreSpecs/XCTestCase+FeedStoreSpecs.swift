//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Mayowa Olunuga on 20/04/2021.
//

import XCTest
import EssentialFeed


extension FeedStoreSpecs where Self : XCTestCase {
    func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut : FeedStore, file : StaticString = #filePath, line : UInt = #line){
        expect(sut, toRetrieve: .success(.none))
    }
    
    func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut : FeedStore, file : StaticString = #filePath, line : UInt = #line) {
        expect(sut, toRetrieveTwice: .success(.none))
    }
    
    func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut : FeedStore, file : StaticString = #filePath, line : UInt = #line) {
        let feeds = uniqueImageFeed().local
        let timeStamp = Date()
        
        insert((feeds, timeStamp), to: sut)
        
        expect(sut, toRetrieve: .success(CachedFeed(feed: feeds, timeStamp: timeStamp)))
    }
    
    func assertThatTestRetrieveHasNoSideEffectOnNonEmptyCache(on sut : FeedStore, file : StaticString = #filePath, line : UInt = #line){
        let feeds = uniqueImageFeed().local
        let timeStamp = Date()
        
        insert((feeds, timeStamp), to: sut)
        
        expect(sut, toRetrieveTwice: .success(CachedFeed(feed: feeds, timeStamp: timeStamp)))
    }
    
    func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)
            
            XCTAssertNil(insertionError, "Expected to insert cache successfully", file: file, line: line)
        }
        
        func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            insert((uniqueImageFeed().local, Date()), to: sut)
            
            let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)
            
            XCTAssertNil(insertionError, "Expected to override cache successfully", file: file, line: line)
        }
        
        func assertThatInsertOverridesPreviouslyInsertedCacheValues(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            insert((uniqueImageFeed().local, Date()), to: sut)
            
            let latestFeed = uniqueImageFeed().local
            let latestTimestamp = Date()
            insert((latestFeed, latestTimestamp), to: sut)
            
            expect(sut, toRetrieve: .success(CachedFeed(feed: latestFeed, timeStamp: latestTimestamp)), file: file, line: line)
        }

        func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            let deletionError = deleteCache(from: sut)
            
            XCTAssertNil(deletionError, "Expected empty cache deletion to succeed", file: file, line: line)
        }
        
        func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            deleteCache(from: sut)
            
            expect(sut, toRetrieve: .success(.none), file: file, line: line)
        }

        func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            insert((uniqueImageFeed().local, Date()), to: sut)
            
            let deletionError = deleteCache(from: sut)
            
            XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed", file: file, line: line)
        }
        
        func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            insert((uniqueImageFeed().local, Date()), to: sut)
            
            deleteCache(from: sut)
            
            expect(sut, toRetrieve: .success(.none), file: file, line: line)
        }
        
        func assertThatSideEffectsRunSerially(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            var completedOperationsInOrder = [XCTestExpectation]()
            
            let op1 = expectation(description: "Operation 1")
            sut.insert(uniqueImageFeed().local, timeStamp: Date()) { _ in
                completedOperationsInOrder.append(op1)
                op1.fulfill()
            }
            
            let op2 = expectation(description: "Operation 2")
            sut.deleteCachedFeed { _ in
                completedOperationsInOrder.append(op2)
                op2.fulfill()
            }
            
            let op3 = expectation(description: "Operation 3")
            sut.insert(uniqueImageFeed().local, timeStamp: Date()) { _ in
                completedOperationsInOrder.append(op3)
                op3.fulfill()
            }
            
            waitForExpectations(timeout: 5.0)
            
            XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], "Expected side-effects to run serially but operations finished in the wrong order", file: file, line: line)
        }

}



extension FeedStoreSpecs where Self : XCTestCase {
    @discardableResult
    func insert(_ cache : (feed : [LocalFeedImage], timestamp : Date), to sut : FeedStore) -> Error?{
        let exp = expectation(description: "Wait for retrieve to complete")
        
        var error : Error?
        sut.insert(cache.feed, timeStamp: cache.timestamp){ insertionError in
            error = insertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return error
    }
    
    @discardableResult
    func deleteCache(from sut : FeedStore,file : StaticString = #filePath, line : UInt = #line) -> Error? {
        var deletionError : Error?
        let exp = expectation(description: "Wait for deletion to complete")
        sut.deleteCachedFeed {error in
            deletionError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }

    

    
    func expect(_ sut : FeedStore, toRetrieve expectedResult : FeedStore.RetrievalResult, file : StaticString = #filePath, line : UInt = #line){
        let exp = expectation(description: "Wait for retrieve to complete")
        
        sut.retrieve { retrievedResult in
            switch (retrievedResult, expectedResult) {
            case (.success(.none), .success(.none)),
                 (.failure, .failure):
                break
            case let (.success(.some(retrievedCache)), .success(.some(expectedCache))):
                XCTAssertEqual(retrievedCache.feed, expectedCache.feed, file : file, line : line)
                XCTAssertEqual(retrievedCache.timeStamp, expectedCache.timeStamp, file : file, line : line)
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file : file, line : line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func expect(_ sut : FeedStore, toRetrieveTwice expectedResult :  FeedStore.RetrievalResult, file : StaticString = #filePath, line : UInt = #line){
        expect(sut, toRetrieve: expectedResult)
        expect(sut, toRetrieve: expectedResult)
    }
    
}
