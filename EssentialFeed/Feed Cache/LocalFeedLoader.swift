//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Mayowa Olunuga on 15/04/2021.
//

import Foundation

public final class LocalFeedLoader{
    private let store : FeedStore
    private let currentDate : ()->Date
    
   public init(store : FeedStore, currentDate : @escaping ()->Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
   public func save(_ items : [FeedItem], completion : @escaping (Error?)->Void){
        store.deleteCachedFeed{ [weak self] error in
            guard let self = self else {return }
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else{
                self.cache(items, with : completion)
            }
        }
    }
    
   private func cache(_ items : [FeedItem], with completion : @escaping (Error?)-> Void) {
        store.insert(items, timeStamp: currentDate()){[weak self] error in
            guard self != nil else {return}
            completion(error)
        }
    }
}

public protocol FeedStore {
    typealias DeletionCompletion = (Error?)-> Void
    typealias InsertionCompletion = (Error?)-> Void
    
    func deleteCachedFeed(completion :@escaping DeletionCompletion)
    func insert(_ items : [FeedItem], timeStamp : Date, completion : @escaping InsertionCompletion)
}
    

