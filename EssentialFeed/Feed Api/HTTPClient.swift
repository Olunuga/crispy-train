//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Mayowa Olunuga on 31/03/2021.
//

import Foundation
public enum HttpClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HttpClient {
    func get(from url : URL, completion : @escaping (HttpClientResult)->Void)
}
