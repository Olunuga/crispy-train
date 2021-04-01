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
    
    
    func test_getFromURL_performsCallWitPassedUrl(){
        
        URLProtocolStub.startInterceptingRequest()
        let passedUrl = URL(string: "http://some-passed-url.com")!
    
        let sut = URLSessionHTTPClient()
       
        let exp = expectation(description: "wait for request")
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, passedUrl)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        sut.get(from:passedUrl){_ in }
        
        wait(for: [exp], timeout: 1.0)
        URLProtocolStub.stopInterceptingRequest()
    }
    
    
    func test_get_fromURL_failsOnRequestError(){
        //arrange
        URLProtocolStub.startInterceptingRequest()
        let url = URL(string: "http://any-url.com")!
        let error = NSError(domain: "Any error", code: 1)
        URLProtocolStub.stub(data : nil, response : nil, error: error)
        
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
        private static var stub : Stub?
        private static var requestObserver : ((URLRequest)->Void)?
        
       private struct Stub {
        let data : Data?
        let response : URLResponse?
            let error : Error?
        }
    
        
        static func stub(data : Data?, response : URLResponse?, error : Error? = nil){
            stub = Stub(data : data, response : response, error: error)
        }
        
        static func startInterceptingRequest(){
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequest(){
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        
        override class func canInit(with request: URLRequest) -> Bool {
           requestObserver?(request)
           return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        
        static func observeRequests(observer : @escaping (_ request : URLRequest)->Void){
            requestObserver = observer
        }
        
        override func startLoading() {
        
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
            
        }
        
        override func stopLoading() {}
        
    }
    
}
