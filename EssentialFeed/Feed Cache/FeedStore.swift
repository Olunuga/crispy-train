//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Mayowa Olunuga on 15/04/2021.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?)-> Void
    typealias InsertionCompletion = (Error?)-> Void
    
    func deleteCachedFeed(completion :@escaping DeletionCompletion)
    func insert(_ items : [LocalFeedImage], timeStamp : Date, completion : @escaping InsertionCompletion)
    
    func retrieve()
}
   
