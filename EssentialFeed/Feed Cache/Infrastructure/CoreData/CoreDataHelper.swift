//
//  CoreDataHelper.swift
//  EssentialFeed
//
//  Created by Mayowa Olunuga on 29/04/2021.
//

import CoreData

extension NSPersistentContainer {
    enum LoadingError: Swift.Error {
        case modelNotFound
        case failedToLoadPersistentStores(Swift.Error)
    }
    
    static func load(storeURL : URL, modelName : String, in bundle : Bundle) throws -> NSPersistentContainer {
        guard let model = NSManagedObjectModel.with(name: modelName, in: bundle) else {
            throw LoadingError.modelNotFound
        }
        
        let description = NSPersistentStoreDescription(url: storeURL)
        let container = NSPersistentContainer(name: modelName, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]
        
        var loadError : Swift.Error?
        container.loadPersistentStores{ loadError = $1}
        try loadError.map { throw LoadingError.failedToLoadPersistentStores($0)}
        
        return container
        
    }
}

private extension NSManagedObjectModel {
    static func with(name : String, in bundle :Bundle) -> NSManagedObjectModel? {
        return bundle.url(forResource: name, withExtension: "momd").flatMap{NSManagedObjectModel(contentsOf: $0)}
    }
}
