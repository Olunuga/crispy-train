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

    
    //MARK: Helpers
    private func makeSUT(currentDate : @escaping ()->Date = Date.init, file: StaticString = #filePath, line: UInt = #line)-> (sut: LocalFeedLoader, store : FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate : currentDate)
        trackForMemoryLeak(sut, file: file, line:  line)
        trackForMemoryLeak(store, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut : LocalFeedLoader, toCompleteWith expectedResult : LoadFeedResult, when action : ()->Void, file : StaticString = #filePath, line : UInt = #line ){
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
    
    private func anyNSError()-> NSError {NSError(domain: "Any error", code: NSURLErrorUnknown, userInfo: ["":""])}
}
