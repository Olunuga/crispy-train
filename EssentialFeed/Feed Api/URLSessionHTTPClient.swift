//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Mayowa Olunuga on 02/04/2021.
//

import Foundation

public class URLSessionHTTPClient : HttpClient {
    private let session : URLSession
   public init(session : URLSession = .shared) {
        self.session = session
    }
    
    private struct UnexpectedValueRepresentation : Error {}
    
    public func get(from url : URL, completion :@escaping (HttpClient.Result)->Void){
        session.dataTask(with: url, completionHandler: {data, response , error  in
            
            completion(Result{
                if let error = error {
                    throw error
                }else if let data = data,  let response = response as?HTTPURLResponse {
                 return ((data, response))
                }
                else{
                    throw UnexpectedValueRepresentation()
                }
            })
            
            
            
        }).resume()
    }
}
