//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedTests
//
//  Created by Mayowa Olunuga on 01/04/2021.
//

import Foundation
import XCTest
import EssentialFeed


class URLSessionHTTPClient {
    private let session : URLSession
    init(session : URLSession) {
        self.session = session
    }
    
    func get(from url : URL, completion :@escaping (HttpClientResult)->Void){
        session.dataTask(with: url, completionHandler: {_, _ , error  in
            if let error = error {
                completion(.failure(error))
            }
            
        }).resume()
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
        sut.get(from: url){ _ in }
        
        //assert
        XCTAssertEqual(task.resumeCallCount,1)
    }
    
    func test_get_fromURL_failsOnRequestError(){
        //arrange
        let url = URL(string: "http:any-url.com")!
        let session = URLSessionSpy()
        let error = NSError(domain: "Any error", code: 1)
        session.stub(url: url, error: error)
        
        //act
        let exp = expectation(description: "Wait for completion")
        
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url){ result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, error)
            default:
                XCTFail("Expected error with \(error) but got \(result)")
            }
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
       
    }
    
    
    
    
    
    
    //MARK: - Helpers
    private class URLSessionSpy : URLSession {
        private var stubs = [URL : Stub]()
        
        private struct Stub {
            let task : URLSessionDataTask
            let error : Error?
        }
        
        override init() {}
        
        func stub(url : URL, task : URLSessionDataTask = FakeURLSessionDataTask(), error : Error? = nil){
            stubs[url] = Stub(task: task, error: error)
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            guard let stub = stubs[url] else {
                fatalError("Couldn't find stub for \(url)")
            }
            completionHandler(nil, nil, stub.error)
            return stub.task
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
