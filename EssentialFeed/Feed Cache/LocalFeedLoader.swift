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
    
   public typealias SaveResult = Error?
   
    
   public init(store : FeedStore, currentDate : @escaping ()->Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
   public func save(_ items : [FeedImage], completion : @escaping (SaveResult)->Void){
        store.deleteCachedFeed{ [weak self] error in
            guard let self = self else {return }
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else{
                self.cache(items, with : completion)
            }
        }
    }
    
    public func load(completion : @escaping (LoadFeedResult) -> Void){
        store.retrieve{ error in
            if let error = error {
                completion(.failure(error))
            }
            
        }
    }
    
   private func cache(_ items : [FeedImage], with completion : @escaping (SaveResult)-> Void) {
    store.insert(items.toLocal(), timeStamp: currentDate()){[weak self] error in
            guard self != nil else {return}
            completion(error)
        }
    }
}


private extension Array where Element == FeedImage {
    func toLocal()-> [LocalFeedImage] {
        return map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}
