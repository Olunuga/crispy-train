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
            do {
                try ManagedCache.find(in: context).map(context.delete)
                completion(nil)
            }catch {
                completion(error)
            }
        }
        
    }
    
    public func insert(_ items: [LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            do {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timeStamp
                managedCache.feeds = ManagedFeedImage.images(from: items, in: context)
               try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            do {
                if let cache = try ManagedCache.find(in: context) {
                    completion(.success(CachedFeed(feed: cache.localFeed, timeStamp: cache.timestamp)))
                }else {
                    completion(.success(.none))
                }
            }catch {
                completion(.failure(error))
            }
        }
    }
    
    private func perform(_ action : @escaping (NSManagedObjectContext) ->Void ){
        let context = self.context
        context.perform {
            action(context)
        }
    }
}
