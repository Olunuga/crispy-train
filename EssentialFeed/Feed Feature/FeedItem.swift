//
//  FeedItem.swift
//  EssentialFeeds
//
//  Created by Mayowa Olunuga on 29/03/2021.
//

import Foundation

public struct FeedItem : Equatable {
    let id : UUID
    let description : String?
    let location : String?
    let imageURL : String
    
}
