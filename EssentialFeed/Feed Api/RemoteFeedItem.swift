//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Mayowa Olunuga on 16/04/2021.
//

import Foundation

 struct RemoteFeedItem : Decodable {
     let id : UUID
     let description : String?
     let location : String?
     let image : URL
}
