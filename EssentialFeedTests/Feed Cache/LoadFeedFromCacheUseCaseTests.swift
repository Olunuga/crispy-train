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
        
        var receivedError : Error?
        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
             case let .failure(error):
                receivedError = error
            default:
                XCTFail("Expected failure, but got \(result)")
            }
            exp.fulfill()
        }
        store.completeRetrieval(with : retrievalError)
        
        wait(for: [exp], timeout: 1.0)
        
        
        XCTAssertEqual(receivedError as NSError?, retrievalError)
    }
    
    
    //MARK: Helpers
    private func makeSUT(currentDate : @escaping ()->Date = Date.init, file: StaticString = #filePath, line: UInt = #line)-> (sut: LocalFeedLoader, store : FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate : currentDate)
        trackForMemoryLeak(sut, file: file, line:  line)
        trackForMemoryLeak(store, file: file, line: line)
        return (sut, store)
    }
    
    private func anyNSError()-> NSError {NSError(domain: "Any error", code: NSURLErrorUnknown, userInfo: ["":""])}
}
