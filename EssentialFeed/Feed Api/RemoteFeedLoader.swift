//
//  RemoteFeedLoader.swift
//  EssentialFeeds
//
//  Created by Mayowa Olunuga on 30/03/2021.
//

import Foundation

public final class RemoteFeedLoader : FeedLoader {
    private let client : HttpClient
    private let url : URL
    public enum Error : Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = FeedLoader.Result
   
    
    public init(url : URL, client : HttpClient) {
        self.client = client
        self.url = url
    }
    
    public func load( completion : @escaping (Result)->Void){
        client.get(from : url){ [weak self] result in
            guard self != nil else {return}
            
            switch result {
            case .success(let data,let response):
                completion(RemoteFeedLoader.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(_ data : Data, from response : HTTPURLResponse) -> FeedLoader.Result {
        do {
            let remoteFeedItems = try FeedItemsMapper.map(data, from: response)
            return .success(remoteFeedItems.toModels())
        }catch {
            return .failure(error)
        }
        
    }
    
}


private extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedImage] {
        map {FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image)}
    }
}
