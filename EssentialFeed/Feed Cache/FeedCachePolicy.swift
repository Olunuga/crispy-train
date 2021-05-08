//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Mayowa Olunuga on 18/04/2021.
//

import Foundation

 final class FeedCachePolicy{
    private static let calendar = Calendar(identifier: .gregorian)
    private static var maxCacheAgeInDays : Int { 7 }
    
    private init() {}
    
   static func validate(_ timeStamp : Date, against date : Date ) -> Bool {
        
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays , to: timeStamp) else {
            return false
        }
        return date < maxCacheAge
    }
    
}
