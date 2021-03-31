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
    
    public typealias Result = LoadFeedResult<Error>
   
    
    public init(url : URL, client : HttpClient) {
        self.client = client
        self.url = url
    }
    
    public func load( completion : @escaping (Result)->Void){
        client.get(from : url){ [weak self] result in
            guard self != nil else {return}
            
            switch result {
            case .success(let data,let response):
                completion(FeedItemsMapper.map(data, from: response))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
    
}

