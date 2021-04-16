//
//  LocalFeedItem.swift
//  EssentialFeed
//
//  Created by Mayowa Olunuga on 16/04/2021.
//

import Foundation

public struct LocalFeedImage : Equatable {
   public let id : UUID
   public let description : String?
   public let location : String?
   public let imageURL : URL
    
    
    public init(id : UUID, description : String?, location : String?, imageUrl : URL){
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageUrl
    }
}
