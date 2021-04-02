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
    
    public func get(from url : URL, completion :@escaping (HttpClientResult)->Void){
        session.dataTask(with: url, completionHandler: {data, response , error  in
            
            if let error = error {
                completion(.failure(error))
            }else if let data = data,  let response = response as?HTTPURLResponse {
                completion(.success(data, response))
            }
            else{
                completion(.failure(UnexpectedValueRepresentation()))
            }
            
        }).resume()
    }
}
