//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by Mayowa Olunuga on 30/03/2021.
//

import XCTest
import EssentialFeed


class RemoteFeedLoaderTest : XCTestCase {
    
    func test_load_doesNotRequestDataFromURL(){
        //arrange
        let (_, client) = MakeSUT()
    
        //assert
        XCTAssertEqual(client.requestedUrls, [])
    }
    
    
    func test_load_requestDataFromURL(){
        //arrange
        let tUrl = URL(string: "a-given-url.com")!
        let (sut, client) = MakeSUT(url: tUrl)
    
        //act
        sut.load{_ in }
        
        //assert
        XCTAssertEqual(client.requestedUrls, [tUrl])
    }
    
    func test_loadTwice_requestDataFromURLTwice(){
        //arrange
        let tUrl = URL(string: "a-given-url.com")!
        let (sut, client) = MakeSUT(url: tUrl)
    
        //act
        sut.load{_ in }
        sut.load{_ in }
        
        //assert
        XCTAssertEqual(client.requestedUrls, [tUrl, tUrl])
    }
    
    func test_load_deliversErrorOnClientError(){
        //arrange
        let (sut, client) = MakeSUT()
        
        //act
        var capturedError = [RemoteFeedLoader.Error]()
        sut.load {capturedError.append($0) }
        
        let error = NSError(domain: "Test", code: 0, userInfo: nil)
        client.complete(with : error)
        
        //assert
        XCTAssertEqual(capturedError, [.connectivity])
       
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse(){
        //arrange
        let (sut, client) = MakeSUT()
        
        let samples  = [199, 201, 300, 400, 500]
        samples.enumerated().forEach{
             index, code  in
            
            //act
            var capturedError = [RemoteFeedLoader.Error]()
            sut.load {capturedError.append($0) }
            
            client.complete(withStatusCode : code, at: index )
            
            //assert
            XCTAssertEqual(capturedError, [.invalidData])
        }
        
       
    }
    
    
    
    //Mark: Helpers
    func MakeSUT(url : URL = URL(string: "some-given-url")!)->(sut : RemoteFeedLoader, client : HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    
    typealias completionType = (Error?, HTTPURLResponse?)->Void
    class HTTPClientSpy : HttpClient {
        private var messages = [(url : URL, completion : completionType)]()
        var requestedUrls : [URL] {
            messages.map{$0.url}
        }
        
        func get(from url: URL, completion: @escaping completionType) {
            messages.append((url,completion))
        }
        
        func complete(with error : Error, index : Int = 0){
            messages[index].completion(error, nil)
        }
        
        func complete(withStatusCode code : Int,at index : Int = 0){
            messages[index].completion(nil, HTTPURLResponse(url: requestedUrls[index], statusCode: code, httpVersion: nil, headerFields: nil))
        }
        
    }
}

