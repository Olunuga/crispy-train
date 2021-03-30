//
//  RemoteFeedLoader.swift
//  EssentialFeeds
//
//  Created by Mayowa Olunuga on 30/03/2021.
//

import Foundation

public enum HttpClientResult {
    case success(Data,HTTPURLResponse)
    case failure(Error)
}

public protocol HttpClient {
    func get(from url : URL, completion : @escaping (HttpClientResult)->Void)
}

public final class RemoteFeedLoader {
    private let client : HttpClient
    private let url : URL
    public enum Error : Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url : URL, client : HttpClient) {
        self.client = client
        self.url = url
    }
    
    public func load( completion : @escaping (Error)->Void){
        client.get(from : url){
            result in
            switch result {
            case .success:
                completion(.invalidData)
            case .failure:
                completion(.connectivity)
            }
        }
    }
}



