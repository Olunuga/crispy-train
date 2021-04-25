//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Mayowa Olunuga on 20/04/2021.
//

import XCTest
import EssentialFeed


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

    

    
    func expect(_ sut : FeedStore, toRetrieve expectedResult : RetrievedCachedFeedResult, file : StaticString = #filePath, line : UInt = #line){
        let exp = expectation(description: "Wait for retrieve to complete")
        
        sut.retrieve { retrievedResult in
            switch (retrievedResult, expectedResult) {
            case (.empty, .empty),
                 (.failure, .failure):
                break
            case let (.found(retrievedFeed, retrievedTimeStamp), .found(expectedFeed, expectedTimeStamp)):
                XCTAssertEqual(retrievedFeed, expectedFeed, file : file, line : line)
                XCTAssertEqual(retrievedTimeStamp, expectedTimeStamp, file : file, line : line)
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file : file, line : line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func expect(_ sut : FeedStore, toRetrieveTwice expectedResult : RetrievedCachedFeedResult, file : StaticString = #filePath, line : UInt = #line){
        expect(sut, toRetrieve: expectedResult)
        expect(sut, toRetrieve: expectedResult)
    }
    
}
