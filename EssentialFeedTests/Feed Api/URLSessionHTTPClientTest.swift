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
        session.dataTask(with: url, completionHandler: {_, _ , _  in }).resume()
    }
}


class URLSessionHTTPClientTest : XCTestCase {
    
    
    func test_get_fromURL_resumesDataTaskWithURL(){
        //arrange
        let url = URL(string: "http:any-url.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)
        
        //act
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url)
        
        //assert
        XCTAssertEqual(task.resumeCallCount,1)
    }
    
    
    
    
    
    
    //MARK: - Helpers
    private class URLSessionSpy : URLSession {
        private var stubs = [URL : URLSessionDataTask]()
        
        override init() {}
        
        func stub(url : URL, task : URLSessionDataTask){
            stubs[url] = task
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            return stubs[url] ??  FakeURLSessionDataTask()
        }
    }
    
    
    private class FakeURLSessionDataTask : URLSessionDataTask {
        override init() {}
    }
    
    private class URLSessionDataTaskSpy : URLSessionDataTask {
        override init() {}
        var resumeCallCount = 0
        
        override func resume() {
            resumeCallCount += 1
        }
    }
}
