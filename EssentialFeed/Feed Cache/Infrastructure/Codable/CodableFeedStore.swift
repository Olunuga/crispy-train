//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Mayowa Olunuga on 19/04/2021.
//

import Foundation

public class CodableFeedStore : FeedStore {
    private let queue =  DispatchQueue(label: "\(CodableFeedStore.self) Queue", qos: .userInitiated)
    private let storeURL : URL
    public init(storeURL : URL) {
        self.storeURL = storeURL
    }
    
    private struct Cache : Codable {
        let feed : [CodableFeedImage]
        let timeStamp : Date
        
        var localFeed : [LocalFeedImage] {
            return feed.map{ $0.local }
        }
    }
    
    private struct CodableFeedImage : Equatable , Codable {
        private let id : UUID
        private let description : String?
        private let location : String?
        private let url : URL
        
        init(_ image : LocalFeedImage){
            self.id = image.id
            self.description = image.description
            self.location = image.location
            self.url = image.url
        }
        
        var local : LocalFeedImage {
            LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    
    public func retrieve(completion : @escaping RetrievalCompletion){
        let storeURL = self.storeURL
        queue.async {
            guard let data = try? Data(contentsOf: storeURL) else {
                completion(.success(.none))
                return
            }
            do{
                let decoder = JSONDecoder()
                let cache = try decoder.decode(Cache.self, from: data)
                completion(.success(CachedFeed(feed: cache.localFeed, timeStamp: cache.timeStamp)))
                
            }catch {
                completion(.failure(error))
            }
        }
    }
    
    
    
    public func insert(_ items : [LocalFeedImage], timeStamp : Date, completion : @escaping InsertionCompletion){
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            do {
                let encoder = JSONEncoder()
                let cache = Cache(feed: items.map{ CodableFeedImage.init($0)}, timeStamp: timeStamp)
                let encoded = try encoder.encode(cache)
                try encoded.write(to: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
            
        }
    }
    
    public func deleteCachedFeed(completion :@escaping DeletionCompletion){
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: storeURL.path) else {
                return completion(nil)
            }
            
            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(nil)
            }catch {
                completion(error)
            }
            
        }
    }
}
