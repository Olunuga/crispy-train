//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Mayowa Olunuga on 28/04/2021.
//

import CoreData

private class ManagedCache : NSManagedObject {
    @NSManaged var timestamp : Date
    @NSManaged var feeds : NSOrderedSet
}

private class ManagedFeedImage : NSManagedObject {
    @NSManaged var id : UUID
    @NSManaged var imageDescription : String?
    @NSManaged var location : String?
    @NSManaged var url : URL
    @NSManaged var cache : ManagedCache
}

public final class CoreDataFeedStore : FeedStore {
    private let container : NSPersistentContainer
    private let context : NSManagedObjectContext
    
    public init(bundle : Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "CoreDataFeedStore", in: bundle)
        context = container.newBackgroundContext()
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
    
    public func insert(_ items: [LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
}


extension NSPersistentContainer {
    enum LoadingError: Swift.Error {
        case modelNotFound
        case failedToLoadPersistentStores(Swift.Error)
    }
    
    static func load(modelName : String, in bundle : Bundle) throws -> NSPersistentContainer {
        guard let model = NSManagedObjectModel.with(name: modelName, in: bundle) else {
            throw LoadingError.modelNotFound
        }
        
        let container = NSPersistentContainer(name: modelName, managedObjectModel: model)
        var loadError : Swift.Error?
        container.loadPersistentStores{ loadError = $1}
        try loadError.map { throw LoadingError.failedToLoadPersistentStores($0)}
        
        return container
        
    }
}

extension NSManagedObjectModel {
    static func with(name : String, in bundle :Bundle) -> NSManagedObjectModel? {
        return bundle.url(forResource: name, withExtension: "momd").flatMap{NSManagedObjectModel(contentsOf: $0)}
    }
}
