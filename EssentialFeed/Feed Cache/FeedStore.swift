//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Mayowa Olunuga on 15/04/2021.
//

import Foundation

public typealias CachedFeed  = (feed : [LocalFeedImage], timeStamp : Date)

public protocol FeedStore {
    typealias DeletionResult = Error?
    typealias DeletionCompletion = (DeletionResult)-> Void
    
    typealias InsertionResult = Error?
    typealias InsertionCompletion = (InsertionResult)-> Void
    
    typealias RetrievalResult  = Result<CachedFeed?, Error>
    typealias RetrievalCompletion = (RetrievalResult)-> Void
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed
    func deleteCachedFeed(completion :@escaping DeletionCompletion)
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed
    func insert(_ items : [LocalFeedImage], timeStamp : Date, completion : @escaping InsertionCompletion)
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed
    func retrieve(completion : @escaping RetrievalCompletion)
}
   
