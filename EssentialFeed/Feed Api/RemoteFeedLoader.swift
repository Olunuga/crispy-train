//
//  RemoteFeedLoader.swift
//  EssentialFeeds
//
//  Created by Mayowa Olunuga on 30/03/2021.
//

import Foundation

public protocol HttpClient {
    func get(from url : URL)
}

public final class RemoteFeedLoader {
   private let client : HttpClient
   private let url : URL
    
  public init(url : URL, client : HttpClient) {
        self.client = client
        self.url = url
    }
    
   public func load(){
        client.get(from : url)
    }
}



