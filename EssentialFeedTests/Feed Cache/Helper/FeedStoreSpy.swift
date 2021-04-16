//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Mayowa Olunuga on 16/04/2021.
//

import Foundation
import EssentialFeed

internal class FeedStoreSpy : FeedStore {
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
