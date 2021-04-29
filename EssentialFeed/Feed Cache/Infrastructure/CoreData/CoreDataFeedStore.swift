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
                    completion(.found(feed: cache.localFeed, timeStamp: cache.timestamp))
                }else {
                    completion(.empty)
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


@objc(ManagedCache)
private class ManagedCache : NSManagedObject {
    @NSManaged var timestamp : Date
    @NSManaged var feeds : NSOrderedSet
    
    var localFeed : [LocalFeedImage] {
        return feeds.compactMap {($0 as? ManagedFeedImage)?.local}
    }
    
    static func find(in context : NSManagedObjectContext)  throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }
    
    @discardableResult
    static func newUniqueInstance(in context : NSManagedObjectContext) throws -> ManagedCache{
        try find(in: context).map(context.delete)
        return ManagedCache(context: context)
    }
    
}

@objc(ManagedFeedImage)
private class ManagedFeedImage : NSManagedObject {
    @NSManaged var id : UUID
    @NSManaged var imageDescription : String?
    @NSManaged var location : String?
    @NSManaged var url : URL
    @NSManaged var cache : ManagedCache
    
    
    static func images(from localFeed : [LocalFeedImage], in context : NSManagedObjectContext) -> NSOrderedSet {
        return NSOrderedSet( array: localFeed.map { local in
            let managed = ManagedFeedImage(context: context)
            managed.id = local.id
            managed.imageDescription = local.description
            managed.location = local.location
            managed.url = local.url
            return managed
            
        })
    }
    
    var local : LocalFeedImage {
        return LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
    }
}
