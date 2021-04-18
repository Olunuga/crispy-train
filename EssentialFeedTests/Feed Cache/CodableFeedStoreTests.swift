//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Mayowa Olunuga on 18/04/2021.
//

import XCTest
import EssentialFeed


class CodableFeedStore {
    
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
    
    
    private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
    
    func retrieve(completion : @escaping FeedStore.RetrievalCompletion){
        guard let data = try? Data(contentsOf: storeURL) else {
            completion(.empty)
            return
        }
        
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found(feed: cache.localFeed, timeStamp: cache.timeStamp))
    }
    
   
    
    func insert(_ items : [LocalFeedImage], timeStamp : Date, completion : @escaping FeedStore.InsertionCompletion){
        let encoder = JSONEncoder()
        let cache = Cache(feed: items.map{ CodableFeedImage.init($0)}, timeStamp: timeStamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeURL)
        completion(nil)
    }
}

class CodableFeedStoreTests : XCTestCase {
    

    override class func setUp() {
        super.setUp()
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    override class func tearDown() {
        super.tearDown()
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache(){
        let sut = makeSUT()
        
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
        let sut = makeSUT()
        
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
    
    func test_retrieveAfterInsertingToCache_deliversInsertedValues(){
        let sut = makeSUT()
        let feeds = uniqueImageFeed().local
        let timeStamp = Date()
        
        let exp = expectation(description: "Wait for retrieve to complete")
        sut.insert(feeds, timeStamp: timeStamp){ insertionError in
            XCTAssertNil(insertionError, "Expect insertion error to be nil")
            sut.retrieve { retrievedResult in
            switch retrievedResult {
            case  let .found(localFeeds, retrievedTimeStamp):
            XCTAssertEqual(localFeeds, feeds)
            XCTAssertEqual(timeStamp, retrievedTimeStamp)
                break
            default:
                XCTFail("Expected found result with \(feeds) and \(timeStamp), but got \(retrievedResult) instead")
            }
            
                exp.fulfill()
                
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    
    
    //MARK: HELPER
    func makeSUT(file: StaticString = #filePath, line: UInt = #line)-> CodableFeedStore {
        let sut = CodableFeedStore()
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
    }
}
