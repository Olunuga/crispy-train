//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Mayowa Olunuga on 31/03/2021.
//

import Foundation

public protocol HttpClient {
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    func get(from url : URL, completion : @escaping (Result)->Void)
}
