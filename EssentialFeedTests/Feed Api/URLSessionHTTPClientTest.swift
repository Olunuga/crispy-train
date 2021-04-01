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
    
    struct UnexpectedValueRepresentation : Error {}
    
    func get(from url : URL, completion :@escaping (HttpClientResult)->Void){
        session.dataTask(with: url, completionHandler: {_, _ , error  in
            if let error = error {
                completion(.failure(error))
            }else{
                completion(.failure(UnexpectedValueRepresentation()))
            }
            
        }).resume()
    }
}


class URLSessionHTTPClientTest : XCTestCase {
    
    override class func setUp() {
        URLProtocolStub.startInterceptingRequest()
    }
    
    override class func tearDown() {
        URLProtocolStub.stopInterceptingRequest()
    }
    
    
    func test_getFromURL_performsCallWitPassedUrl(){
        let exp = expectation(description: "wait for request")
        let url = anyURL()
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url,url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from:url){_ in }
        
        wait(for: [exp], timeout: 1.0)
       
    }
    
    
    func test_get_fromURL_failsOnRequestError(){
        let requestError = anyError()
        let receivedError = resultErrorFor(data : nil, response : nil, error: requestError)
        XCTAssertEqual(receivedError as NSError?, requestError)
    }
    
    
    func test_get_fromURL_failsOnNilValues(){
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
    }
    
    func test_get_fromURL_failsOnAllInvalidRepresentationCases(){
        let anyData = Data("any data".utf8)
        let nonHttpURLResponse = URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        let anyHttpURLResponse = HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHttpURLResponse, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHttpURLResponse, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHttpURLResponse, error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHttpURLResponse, error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nonHttpURLResponse, error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: anyHttpURLResponse, error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nonHttpURLResponse, error: nil))
    }
    
    
    
    
    
    
    //MARK: - Helpers
    
    private func makeSUT(file : StaticString  = #filePath, line : UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeak(instance:sut , file: file, line: line)
        return sut
    }
    
    private func anyURL() -> URL {URL(string: "http://any-url.com")!}
    
    private func anyError()-> NSError {NSError(domain: "Any error", code: 1)}
    
    
    private func resultErrorFor(data : Data?, response : URLResponse?, error : Error?, file : StaticString  = #filePath, line : UInt = #line) -> Error? {
        URLProtocolStub.stub(data : data, response : response, error: error)
        
        let exp = expectation(description: "Wait for completion")
    
        let sut = makeSUT(file: file, line : line)
        
        var capturedError : Error?
        sut.get(from: anyURL()){ result in
            switch result {
            case let .failure(receivedError as NSError):
                capturedError = receivedError
            default:
                XCTFail("Expected failure, got \(result)", file: file, line: line)
            }
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return capturedError
    }

    
    
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
