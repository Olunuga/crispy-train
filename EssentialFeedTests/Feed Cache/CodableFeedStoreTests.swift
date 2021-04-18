//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Mayowa Olunuga on 18/04/2021.
//

import XCTest
import EssentialFeed


class CodableFeedStore {
    
    func retrieve(completion : @escaping FeedStore.RetrievalCompletion){
        completion(.empty)
    }
}

class CodableFeedStoreTests : XCTestCase {
    
    func test_retrieve_deliversEmptyOnEmptyCache(){
        let sut = CodableFeedStore()
        
        let exp = expectation(description: "Wait for retrieve to complete")
        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty result but got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_hasNoSideEffectOnEmptyCache(){
        let sut = CodableFeedStore()
        
        let exp = expectation(description: "Wait for retrieve to complete")
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
            switch (firstResult, secondResult) {
            case (.empty, .empty):
                break
            default:
                XCTFail("Expected empty result in both cases, but got \(firstResult) and \(secondResult) instead")
            }
            
                exp.fulfill()
                
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
