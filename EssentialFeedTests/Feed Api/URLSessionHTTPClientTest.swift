//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedTests
//
//  Created by Mayowa Olunuga on 01/04/2021.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClientTest : XCTestCase {
    
    override func setUp() {
        URLProtocolStub.startInterceptingRequest()
    }
    
    override func tearDown() {
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
        let requestError = anyNSError()
        let receivedError = resultErrorFor(data : nil, response : nil, error: requestError)
        XCTAssertEqual(receivedError as NSError?, requestError)
    }
    
    
    func test_get_fromURL_failsOnNilValues(){
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
    }
    
    func test_get_fromURL_failsOnAllInvalidRepresentationCases(){
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHttpURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHttpURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHttpURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHttpURLResponse(), error: nil))
    }
    
    
    func test_get_FromURl_succeedsOnHTTPURLResponseWithData() {
        let passedData = anyData()
        let response = anyHTTPURLResponse()
        
        let receivedResult = resultValuesFor(data: passedData, response: anyHTTPURLResponse(), error: nil)
        
        XCTAssertEqual(receivedResult?.data, passedData)
        XCTAssertEqual(receivedResult?.response.url, response.url)
        XCTAssertEqual(receivedResult?.response.statusCode, response.statusCode)
    
    }
    
    
    func test_get_FromURl_succeedsWithEmptyDataOnHTTPURLResponseWithNilData() {
        let response = anyHTTPURLResponse()
        
        let receivedResult = resultValuesFor(data: nil, response: anyHTTPURLResponse(), error: nil)
        
        let emptyData = Data()
        XCTAssertEqual(receivedResult?.data, emptyData)
        XCTAssertEqual(receivedResult?.response.url, response.url)
        XCTAssertEqual(receivedResult?.response.statusCode, response.statusCode)
    }
    
    
    
    
    
    
    //MARK: - Helpers
    
    
    private func makeSUT(file : StaticString  = #filePath, line : UInt = #line) -> HttpClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeak(instance:sut , file: file, line: line)
        return sut
    }
    
    private func anyURL() -> URL {URL(string: "http://any-url.com")!}
    
    private func anyNSError()-> NSError {NSError(domain: "Any error", code: NSURLErrorUnknown, userInfo: ["":""])}
    
    private func anyData() -> Data {Data("any data".utf8)}
    
    private func nonHttpURLResponse() -> URLResponse { URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)}
    
    private func anyHTTPURLResponse() -> HTTPURLResponse { HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!}
    
    
    private func resultErrorFor(data : Data?, response : URLResponse?, error : Error?, file : StaticString  = #filePath, line : UInt = #line) -> Error? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
            switch result {
            case let .failure(receivedError as NSError):
                return receivedError
            default:
                XCTFail("Expected failure, got \(result)", file: file, line: line)
                return nil
            }
        
    }
    
    
    private func resultValuesFor(data : Data?, response : URLResponse?, error : Error?, file : StaticString  = #filePath, line : UInt = #line) -> (data: Data, response : HTTPURLResponse)? {

        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
            switch result {
            case let .success(data, response):
                return (data, response)
            default:
                XCTFail("Expected success, got \(result)", file: file, line: line)
                return nil
    
          }
       
    }
    
    
    private func resultFor(data : Data?, response : URLResponse?, error : Error?, file : StaticString  = #filePath, line : UInt = #line) -> HttpClientResult{
        URLProtocolStub.stub(data : data, response : response, error: error)
        
        let exp = expectation(description: "Wait for completion")
    
        let sut = makeSUT(file: file, line : line)
        
        var capturedResult : HttpClientResult!
        sut.get(from: anyURL()){ result in
            capturedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return capturedResult
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
