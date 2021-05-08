//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Mayowa Olunuga on 28/04/2021.
//

import CoreData

public final class CoreDataFeedStore : FeedStore {
    private let container : NSPersistentContainer
    private let context : NSManagedObjectContext
    
    public init(storeURL : URL, bundle : Bundle = .main) throws {
        container = try NSPersistentContainer.load(storeURL : storeURL, modelName: "CoreDataFeedStore", in: bundle)
        context = container.newBackgroundContext()
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        perform { context in
            completion (
                Result {
                    try ManagedCache.find(in: context).map(context.delete)
                }
            )
        }
        
    }
    
    public func insert(_ items: [LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            completion( Result {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timeStamp
                managedCache.feeds = ManagedFeedImage.images(from: items, in: context)
                try context.save()
            })
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            completion( Result {
                try ManagedCache.find(in: context).map {
                    return CachedFeed(feed: $0.localFeed, timeStamp: $0.timestamp)
                }
            })
        }
    }
    
    private func perform(_ action : @escaping (NSManagedObjectContext) ->Void ){
        let context = self.context
        context.perform {
            action(context)
        }
    }
}
