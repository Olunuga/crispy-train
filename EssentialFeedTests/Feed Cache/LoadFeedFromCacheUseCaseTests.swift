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
    
    
    //MARK: Helpers
    private func makeSUT(currentDate : @escaping ()->Date = Date.init, file: StaticString = #filePath, line: UInt = #line)-> (sut: LocalFeedLoader, store : FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate : currentDate)
        trackForMemoryLeak(sut, file: file, line:  line)
        trackForMemoryLeak(store, file: file, line: line)
        return (sut, store)
    }
    
    private class FeedStoreSpy : FeedStore {
        private var deletionCompletions = [DeletionCompletion]()
        private var insertionCompletions = [DeletionCompletion]()
        
        
        enum ReceivedMessage : Equatable {
            case deleteCacheFeed
            case insert([LocalFeedImage], Date)
        }
        private(set) var receivedMessages = [ReceivedMessage]()
       
        
        func deleteCachedFeed(completion :@escaping DeletionCompletion){
            receivedMessages.append(.deleteCacheFeed)
            deletionCompletions.append(completion)
        }
        
        func insert(_ items : [LocalFeedImage], timeStamp : Date, completion : @escaping InsertionCompletion){
            receivedMessages.append(.insert(items, timeStamp))
            insertionCompletions.append(completion)
        }
        
        func completeDeletionWith(with error : NSError, at index : Int = 0){
            deletionCompletions[index](error)
        }
        
        func completeInsertionWith(with error : NSError, at index : Int = 0){
            insertionCompletions[index](error)
        }
        
        func completeDeletionSuccessfully(at index : Int = 0){
            deletionCompletions[index](nil)
        }
        
        func completeInsertionSuccessfully(at index:  Int = 0){
            insertionCompletions[index](nil)
        }
    }
}
