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
    let calendar = Calendar(identifier: .gregorian)
    
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
        store.retrieve{[weak self]  result in
            guard let self = self else {return}
            
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .found(feed, timeStamp) where self.validate(timeStamp):
                completion(.success(feed.toModels()))
            case .found:
                self.store.deleteCachedFeed{_ in }
                completion(.success([]))
            case .empty:
                completion(.success([]))
            }
        }
    }
    
    public func validateCache(){
        store.retrieve {_ in }
        store.deleteCachedFeed{_ in }
    }
    
   private func cache(_ items : [FeedImage], with completion : @escaping (SaveResult)-> Void) {
    store.insert(items.toLocal(), timeStamp: currentDate()){[weak self] error in
            guard self != nil else {return}
            completion(error)
        }
    }
    
    private var maxCacheAgeInDays : Int { 7 }
    
    
    private func validate(_ timeStamp : Date) -> Bool {
        
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays , to: timeStamp) else {
            return false
        }
        return currentDate() < maxCacheAge
    }
}


private extension Array where Element == FeedImage {
    func toLocal()-> [LocalFeedImage] {
        return map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels()-> [FeedImage] {
        return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}

