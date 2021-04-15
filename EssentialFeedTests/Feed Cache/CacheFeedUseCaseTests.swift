//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Mayowa Olunuga on 15/04/2021.
//

import Foundation
import XCTest

class LocalFeedLoader{
    let store : FeedStore
    
    init(store : FeedStore) {
        self.store = store
    }
}

class FeedStore {
    var deleteCacheFeedCallCount = 0
}


class CacheFeedUseCaseTests : XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation(){
        let store = FeedStore()
        let _ = LocalFeedLoader(store : store)
        
        XCTAssertEqual(store.deleteCacheFeedCallCount, 0)
    }
}
