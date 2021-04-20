//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Mayowa Olunuga on 18/04/2021.
//

import XCTest
import EssentialFeed

protocol FeedStoreSpecs {
     func test_retrieve_deliversEmptyOnEmptyCache()
     func test_retrieve_hasNoSideEffectOnEmptyCache()
     func test_retrieve_deliversFoundValuesOnNonEmptyCache()
     func test_retrieve_hasNoSideEffectOnNonEmptyCache()
   
     func test_insert_deliversNoErrorOnEmptyCache()
     func test_insert_overridesPreviouslyCachedValue()
     func test_insert_deliversNoErrorOnNonEmptyCache()
    
     func test_delete_deliversNoErrorOnEmptyCache()
     func test_delete_hasNoSideEffectOnEmptyCache()
     func test_delete_deliversNoErrorOnNonEmptyCache()
     func test_delete_emptiesPreviouslyInsertedCache()
     
     func test_storeSideEffects_runSerially()
}


protocol FailableRetreiveFeedStoreSpecs {
    func test_retrieve_deliversFailureOnRetrievalError()
    func test_retrieve_hasNoSideEffectOnFailure()
}

protocol FailableInsertFeedStoreSpecs {
    func test_insert_deliversErrorOnInsertionError()
    func test_insert_hasNoSideEffectInsertionError()
}

protocol FailableDeleteFeedStoreSpecs {
    func test_delete_deliversErrorOnDeletionError()
    func test_delete_hasNoSideEffectOnDeletionError()
}

class CodableFeedStoreTests : XCTestCase {
    
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
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_retrieve_hasNoSideEffectOnEmptyCache(){
        let sut = makeSUT()
        
        expect(sut, toRetrieveTwice: .empty)
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache(){
        let sut = makeSUT()
        let feeds = uniqueImageFeed().local
        let timeStamp = Date()
        
        insert((feeds, timeStamp), to: sut)
        
        expect(sut, toRetrieve: .found(feed: feeds, timeStamp: timeStamp))
    }
    
    
    func test_retrieve_hasNoSideEffectOnNonEmptyCache(){
        let sut = makeSUT()
        let feeds = uniqueImageFeed().local
        let timeStamp = Date()
        
        insert((feeds, timeStamp), to: sut)
        
        expect(sut, toRetrieveTwice: .found(feed: feeds, timeStamp: timeStamp))
    }
    
    func test_retrieve_deliversFailureOnRetrievalError(){
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL : storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieve: .failure(anyNSError()))
    }
    
    func test_retrieve_hasNoSideEffectOnFailure(){
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL : storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieveTwice: .failure(anyNSError()))
    }
    
    func test_insert_deliversNoErrorOnEmptyCache(){
        let sut = makeSUT()
        
        let firstInsertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        XCTAssertNil(firstInsertionError, "Expected to insert cache successfully")
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache(){
        let sut = makeSUT()
        
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        let latestInsertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        XCTAssertNil(latestInsertionError, "Expected to override cache successfully")
    }
    
    
    func test_insert_overridesPreviouslyCachedValue(){
        let sut = makeSUT()
        
        insert((uniqueImageFeed().local, Date()), to: sut)
       
        let latestFeed = uniqueImageFeed().local
        let latesTimestamp = Date()
        insert((latestFeed, latesTimestamp), to: sut)
        expect(sut, toRetrieve: .found(feed: latestFeed, timeStamp: latesTimestamp))
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
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected deletion to complete successfully")
    }
    
    func test_delete_hasNoSideEffectOnEmptyCache(){
        let sut = makeSUT()
        deleteCache(from: sut)
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache(){
        let sut = makeSUT()
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache(){
        let sut = makeSUT()
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected deletion to complete successfully")
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
        var completedOperationsInOrder = [XCTestExpectation]()
        
        
        let op1 = expectation(description: "Operation 1")
        sut.insert(uniqueImageFeed().local, timeStamp: Date()) { _ in
            completedOperationsInOrder.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Operation 2")
        sut.deleteCachedFeed{ _ in
            completedOperationsInOrder.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Operation 3")
        sut.insert(uniqueImageFeed().local, timeStamp: Date()) { _ in
            completedOperationsInOrder.append(op3)
            op3.fulfill()
        }
        waitForExpectations(timeout: 5.0)
        
        XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], "Expected side effects to run serially but operations finished in the wrong order")
    }
    
    
    //MARK: HELPER
    func makeSUT(storeURL : URL? = nil, file: StaticString = #filePath, line: UInt = #line)-> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
    
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
