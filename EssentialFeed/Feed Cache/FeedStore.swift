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
    func insert(_ items : [LocalFeedItem], timeStamp : Date, completion : @escaping InsertionCompletion)
}
   

public struct LocalFeedItem : Equatable {
   public let id : UUID
   public let description : String?
   public let location : String?
   public let imageURL : URL
    
    
    public init(id : UUID, description : String?, location : String?, imageUrl : URL){
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageUrl
    }
}
