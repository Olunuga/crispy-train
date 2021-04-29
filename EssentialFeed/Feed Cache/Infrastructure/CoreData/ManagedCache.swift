//
//  ManagedCache.swift
//  EssentialFeed
//
//  Created by Mayowa Olunuga on 29/04/2021.
//

import CoreData

@objc(ManagedCache)
class ManagedCache : NSManagedObject {
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
