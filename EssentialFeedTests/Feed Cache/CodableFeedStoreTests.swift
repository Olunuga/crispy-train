//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Mayowa Olunuga on 18/04/2021.
//

import XCTest
import EssentialFeed

class CodableFeedStoreTests : XCTestCase, FeedStoreSpecs, FailableFeedStoreSpecs {
    
    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoSideEffects()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache(){
        let sut = makeSUT()
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
        
    }
    
    func test_retrieve_hasNoSideEffectOnEmptyCache(){
        let sut = makeSUT()
        
        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache(){
        let sut = makeSUT()
        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
    }
    
    
    func test_retrieve_hasNoSideEffectOnNonEmptyCache(){
        let sut = makeSUT()
       assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
    }
    
    func test_retrieve_deliversFailureOnRetrievalError(){
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL : storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
       
    }
    
    func test_retrieve_hasNoSideEffectOnFailure(){
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL : storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)
    }
    
    func test_insert_deliversNoErrorOnEmptyCache(){
        let sut = makeSUT()
        assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache(){
        let sut = makeSUT()
        assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
    }
    
    
    func test_insert_overridesPreviouslyCachedValue(){
        let sut = makeSUT()
       assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
    }
    
    
    func test_insert_deliversErrorOnInsertionError(){
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL : invalidStoreURL)
        let feeds = uniqueImageFeed().local
        let timeStamp = Date()
        
        let insertionError = insert((feeds, timeStamp), to: sut)
        XCTAssertNotNil(insertionError)
    }
    
    func test_insert_hasNoSideEffectInsertionError(){
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL : invalidStoreURL)
        let feeds = uniqueImageFeed().local
        let timeStamp = Date()
        
        insert((feeds, timeStamp), to: sut)
        expect(sut, toRetrieve: .empty)
    }
    
    
    func test_delete_deliversNoErrorOnEmptyCache(){
        let sut = makeSUT()
        assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    func test_delete_hasNoSideEffectOnEmptyCache(){
        let sut = makeSUT()
        assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache(){
        let sut = makeSUT()
        assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache(){
        let sut = makeSUT()
        assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
    }
    
    
    func test_delete_deliversErrorOnDeletionError(){
        let nonDeletionPermissionUrl = cachesDirectory()
        let sut = makeSUT(storeURL : nonDeletionPermissionUrl)
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNotNil(deletionError, "Expected deletion error")
    }
    func test_delete_hasNoSideEffectOnDeletionError(){
        let nonDeletionPermissionUrl = cachesDirectory()
        let sut = makeSUT(storeURL : nonDeletionPermissionUrl)
        
        deleteCache(from: sut)
        expect(sut, toRetrieve: .empty)
    }
    
    func test_storeSideEffects_runSerially(){
        let sut = makeSUT()
       assertThatSideEffectsRunSerially(on: sut)
    }
    
    
    //MARK: HELPER
    func makeSUT(storeURL : URL? = nil, file: StaticString = #filePath, line: UInt = #line)-> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
    private func testSpecificStoreURL()-> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    private func setupEmptyStoreState(){
        deleteStoreArtifacts()
    }
    
    private func undoSideEffects(){
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts(){
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
