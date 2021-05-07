//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Mayowa Olunuga on 15/04/2021.
//

import Foundation

public enum CachedFeed {
    case empty
    case found(feed : [LocalFeedImage], timeStamp : Date)
}

public protocol FeedStore {
    typealias DeletionCompletion = (Error?)-> Void
    typealias InsertionCompletion = (Error?)-> Void
    
    typealias RetrievalResult  = Result<CachedFeed, Error>
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
   
