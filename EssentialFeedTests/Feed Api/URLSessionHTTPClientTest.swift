//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedTests
//
//  Created by Mayowa Olunuga on 01/04/2021.
//

import XCTest
import EssentialFeed


class URLSessionHTTPClient {
    private let session : URLSession
    init(session : URLSession = .shared) {
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
    
    func test_get_fromURL_failsOnRequestError(){
        //arrange
        URLProtocolStub.startInterceptingRequest()
        let url = URL(string: "http:any-url.com")!
        let error = NSError(domain: "Any error", code: 1)
        URLProtocolStub.stub(url: url, error: error)
        
        //act
        let exp = expectation(description: "Wait for completion")
        
        let sut = URLSessionHTTPClient()
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
        URLProtocolStub.stopInterceptingRequest()
    }
    
    
    
    
    
    
    //MARK: - Helpers
    private class URLProtocolStub : URLProtocol {
       private static var stubs = [URL : Stub]()
        
       private struct Stub {
            let error : Error?
        }
    
        
        static func stub(url : URL, error : Error? = nil){
            stubs[url] = Stub(error: error)
        }
        
        static func startInterceptingRequest(){
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequest(){
            URLProtocol.unregisterClass(URLProtocolStub.self)
        }
        
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else { return false }
            
            return URLProtocolStub.stubs[url] != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let url = request.url , let stub = URLProtocolStub.stubs[url] else { return }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
            
        }
        
        override func stopLoading() {}
        
    }
    
}
