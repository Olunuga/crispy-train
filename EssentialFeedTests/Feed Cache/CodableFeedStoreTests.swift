//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Mayowa Olunuga on 18/04/2021.
//

import XCTest
import EssentialFeed


class CodableFeedStore {
    private let storeURL : URL
    init(storeURL : URL) {
        self.storeURL = storeURL
    }
    
    private struct Cache : Codable {
        let feed : [CodableFeedImage]
        let timeStamp : Date
        
        var localFeed : [LocalFeedImage] {
            return feed.map{ $0.local }
        }
    }
    
    private struct CodableFeedImage : Equatable , Codable {
        private let id : UUID
        private let description : String?
        private let location : String?
        private let url : URL
        
        init(_ image : LocalFeedImage){
            self.id = image.id
            self.description = image.description
            self.location = image.location
            self.url = image.url
        }
        
        var local : LocalFeedImage {
            LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    
    func retrieve(completion : @escaping FeedStore.RetrievalCompletion){
        guard let data = try? Data(contentsOf: storeURL) else {
            completion(.empty)
            return
        }
        do{
            let decoder = JSONDecoder()
            let cache = try decoder.decode(Cache.self, from: data)
            completion(.found(feed: cache.localFeed, timeStamp: cache.timeStamp))
            
        }catch {
            completion(.failure(error))
        }
    }
    
    
    
    func insert(_ items : [LocalFeedImage], timeStamp : Date, completion : @escaping FeedStore.InsertionCompletion){
        
        do {
            let encoder = JSONEncoder()
            let cache = Cache(feed: items.map{ CodableFeedImage.init($0)}, timeStamp: timeStamp)
            let encoded = try encoder.encode(cache)
            try encoded.write(to: storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    func deleteCachedFeed(completion :@escaping FeedStore.DeletionCompletion){
        do {
            try FileManager.default.removeItem(at: storeURL)
            completion(nil)
        }catch {
            completion(error)
        }
    }
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
    
    
    func test_insert_overridesPreviouslyCachedValue(){
        let sut = makeSUT()
        
        let firstInsertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        XCTAssertNil(firstInsertionError, "Expected to insert cache successfully")
        
        let latestFeed = uniqueImageFeed().local
        let latesTimestamp = Date()
        let latestInsertionError = insert((latestFeed, latesTimestamp), to: sut)
        XCTAssertNil(latestInsertionError, "Expected to override cache successfully")
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
    
    
    func test_delete_hasNoSideEffectOnEmptyCache(){
        let sut = makeSUT()
        deleteCache(from: sut)
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache(){
        let sut = makeSUT()
        let feeds = uniqueImageFeed().local
        let timeStamp = Date()
        
        insert((feeds, timeStamp), to: sut)
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected deletion to complete successfully")
        
        expect(sut, toRetrieve: .empty)
    }
    
    
    func test_delete_deliversErrorOnDeletionError(){
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL : invalidStoreURL)
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNotNil(deletionError, "Expected deletion error")
    }
    
    
    //MARK: HELPER
    func makeSUT(storeURL : URL? = nil, file: StaticString = #filePath, line: UInt = #line)-> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
    
    @discardableResult
    func insert(_ cache : (feed : [LocalFeedImage], timestamp : Date), to sut : CodableFeedStore) -> Error?{
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
    func deleteCache(from sut : CodableFeedStore,file : StaticString = #filePath, line : UInt = #line) -> Error? {
        var deletionError : Error?
        let exp = expectation(description: "Wait for deletion to complete")
        sut.deleteCachedFeed {error in
            deletionError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }

    

    
    func expect(_ sut : CodableFeedStore, toRetrieve expectedResult : RetrievedCachedFeedResult, file : StaticString = #filePath, line : UInt = #line){
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
    
    func expect(_ sut : CodableFeedStore, toRetrieveTwice expectedResult : RetrievedCachedFeedResult, file : StaticString = #filePath, line : UInt = #line){
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
}
