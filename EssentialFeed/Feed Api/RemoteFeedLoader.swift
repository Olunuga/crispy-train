//
//  RemoteFeedLoader.swift
//  EssentialFeeds
//
//  Created by Mayowa Olunuga on 30/03/2021.
//

import Foundation

public final class RemoteFeedLoader {
    private let client : HttpClient
    private let url : URL
    public enum Error : Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result : Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(url : URL, client : HttpClient) {
        self.client = client
        self.url = url
    }
    
    public func load( completion : @escaping (Result)->Void){
        client.get(from : url){
            result in
            switch result {
            case .success(let data,let response):
                if let items = try? FeedItemsMapper.map(data, response) {
                    completion(.success(items))
                }else{
                    completion(.failure(.invalidData))
                }
               
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

