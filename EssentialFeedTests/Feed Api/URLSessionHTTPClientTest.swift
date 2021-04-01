//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedTests
//
//  Created by Mayowa Olunuga on 01/04/2021.
//

import Foundation
import XCTest


class URLSessionHTTPClient {
    private let session : URLSession
    init(session : URLSession) {
        self.session = session
    }
    
    func get(from url : URL){
        session.dataTask(with: url, completionHandler: {_, _ , _  in })
    }
}


class URLSessionHTTPClientTest : XCTestCase {
    
    func test_get_fromURL_createsDataTaskWithURL(){
        let url = URL(string: "http:any-url.com")!
        let session = URLSessionSpy()
      
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url)
        
        XCTAssertEqual(session.receivedUrls, [url])
    }
    
    
    
    
    
    
    //MAKRL - Helpers
    private class URLSessionSpy : URLSession {
        var receivedUrls = [URL]()
        
        override init() {}
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedUrls.append(url)
            return FakeURLSessionDataTask()
        }
    }
    
    
    private class FakeURLSessionDataTask : URLSessionDataTask {
        override init() {}
    }
}
