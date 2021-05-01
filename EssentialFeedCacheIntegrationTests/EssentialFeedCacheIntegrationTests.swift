//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by Mayowa Olunuga on 01/05/2021.
//

import XCTest
import EssentialFeed

class EssentialFeedCacheIntegrationTests: XCTestCase {
    
    
    
    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffect()
    }

    func test_local_deliversNoItemOnEmptyCache(){
        let sut = makeSUT()
        expect(sut, toLoad: [])
    }
    
    
    func test_load_deliversItemsSavedOnASeparateInstance(){
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let feed = uniqueImageFeed().model
        
        save(feed: feed, with: sutToPerformSave)
        expect(sutToPerformLoad, toLoad: feed)
        
    }
    
    func test_save_overridesItemsSavedOnASeparateInstance(){
        let sutToPerformFirstSave = makeSUT()
        let sutToPerformLastSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let firstFeed = uniqueImageFeed().model
        let lastFeed = uniqueImageFeed().model
        
        
        save(feed: firstFeed, with: sutToPerformFirstSave)
        save(feed: lastFeed, with: sutToPerformLastSave)
        expect(sutToPerformLoad, toLoad: lastFeed)
    }
    
    
    
    //MARK: Helper
    func makeSUT(file : StaticString = #filePath, line : UInt = #line)-> LocalFeedLoader {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeUrl = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeUrl, bundle: storeBundle)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeak(sut, file:file, line : line)
        trackForMemoryLeak(sut, file:file, line : line)
        return sut
    }
    
    
    func expect(_ sut : LocalFeedLoader, toLoad expectedFeed : [FeedImage], file : StaticString = #filePath, line : UInt = #line) {
        let exp = expectation(description: "Wait for load")
        sut.load{ result in
            switch result {
            case let .success(imageFeed):
                XCTAssertEqual(imageFeed, expectedFeed, "Expected empty feed", file: file, line: line)
            case let .failure(error):
                XCTFail("Expected successful feed result, but got \(error) ",  file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    
    func save(feed : [FeedImage], with sut : LocalFeedLoader, file : StaticString = #filePath, line : UInt = #line){
        let saveExp = expectation(description: "Wait for save completion")
        sut.save(feed){ saveError in
            XCTAssertNil(saveError, "Expected to save feed successfully", file: file, line: line)
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
    }
    
    func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    func setupEmptyStoreState(){
       deleteStoreArtifacts()
    }
    
    func undoStoreSideEffect(){
        deleteStoreArtifacts()
    }
    
    
    func deleteStoreArtifacts(){
         try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }

}
