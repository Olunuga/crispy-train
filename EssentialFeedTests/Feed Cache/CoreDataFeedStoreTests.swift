//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Mayowa Olunuga on 25/04/2021.
//

import XCTest
import EssentialFeed
import CoreData

private class ManagedCache : NSManagedObject {
    @NSManaged var timestamp : Date
    @NSManaged var feeds : NSOrderedSet
}

private class ManagedFeedImage : NSManagedObject {
    @NSManaged var id : UUID
    @NSManaged var imageDescription : String?
    @NSManaged var location : String?
    @NSManaged var url : URL
    @NSManaged var cache : ManagedCache
}

public final class CoreDataFeedStore : FeedStore {
    
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
    
    public func insert(_ items: [LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
    
    
}

class CoreDataFeedStoreTests : XCTestCase, FeedStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache() {
       let sut = makeSUT()
       assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()
        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        //let sut = makeSUT()
       // assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectOnNonEmptyCache() {
        
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        
    }
    
    func test_insert_overridesPreviouslyCachedValue() {
        
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        
    }
    
    func test_delete_hasNoSideEffectOnEmptyCache() {
        
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        
    }
    
    func test_storeSideEffects_runSerially() {
        
    }
    
    
    //MARK: HELPER
    
    func makeSUT()-> FeedStore {
        let sut = CoreDataFeedStore()
        trackForMemoryLeak(sut)
        return sut
    }

    
}
