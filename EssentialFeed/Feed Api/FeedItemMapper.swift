//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by Mayowa Olunuga on 31/03/2021.
//

import Foundation

 final class FeedItemsMapper {
    private struct Root: Decodable {
        let items : [RemoteFeedItem]
    }
    
    
    static var OK_200 : Int {return 200}
    
     static func map(_ data : Data, from response : HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data)  else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.items
        
    }
}
