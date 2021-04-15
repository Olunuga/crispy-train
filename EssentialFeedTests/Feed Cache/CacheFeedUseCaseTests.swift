//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Mayowa Olunuga on 15/04/2021.
//
import XCTest
import EssentialFeed

class LocalFeedLoader{
    let store : FeedStore
    
    init(store : FeedStore) {
        self.store = store
    }
    
    func save(_ items : [FeedItem]){
        store.deleteCachedFeed()
    }
}

class FeedStore {
    var deleteCacheFeedCallCount = 0
    
    func deleteCachedFeed(){
        deleteCacheFeedCallCount += 1
    }
}


class CacheFeedUseCaseTests : XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation(){
        let store = FeedStore()
        _ = LocalFeedLoader(store : store)
        
        XCTAssertEqual(store.deleteCacheFeedCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion(){
        let store = FeedStore()
        let sut = LocalFeedLoader(store : store)
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        
        XCTAssertEqual(store.deleteCacheFeedCallCount, 1)
    }
    
    
    
    //MARK: Helpers
    private func uniqueItem()-> FeedItem {
        return FeedItem(id: UUID(), description: "any-description", location: "any-location", imageUrl: anyURL() )
    }
    
    private func anyURL() -> URL {URL(string: "http://any-url.com")!}
}
