//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Mayowa Olunuga on 16/04/2021.
//

import Foundation
import EssentialFeed

 class FeedStoreSpy : FeedStore {
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    private var retrievalCompletions = [RetrievalCompletion]()
    
    
    enum ReceivedMessage : Equatable {
        case deleteCacheFeed
        case insert([LocalFeedImage], Date)
        case retrieve
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
    
    func retrieve(completion : @escaping RetrievalCompletion) {
        retrievalCompletions.append(completion)
        receivedMessages.append(.retrieve)
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
    
    func completeRetrieval(with error : NSError, at index : Int = 0){
        retrievalCompletions[index](.failure(error))
    }
    
    func completeRetrievalWithAnEmptyCache(at index: Int = 0){
        retrievalCompletions[index](.success(.empty))
    }
    
    func completeRetrieval(with feed : [LocalFeedImage], timeStamp : Date, at index : Int = 0){
        retrievalCompletions[index](.success(.found(feed :feed, timeStamp: timeStamp)))
    }
}
