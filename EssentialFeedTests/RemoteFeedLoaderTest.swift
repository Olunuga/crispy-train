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
        sut.load()
        
        //assert
        XCTAssertEqual(client.requestedUrls, [tUrl])
    }
    
    func test_loadTwice_requestDataFromURLTwice(){
        //arrange
        let tUrl = URL(string: "a-given-url.com")!
        let (sut, client) = MakeSUT(url: tUrl)
    
        //act
        sut.load()
        sut.load()
        
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
        client.completions[0](error)
        
        //assert
        XCTAssertEqual(capturedError, [.connectivity])
       
    }
    
    
    
    //Mark: Helpers
    func MakeSUT(url : URL = URL(string: "some-given-url")!)->(sut : RemoteFeedLoader, client : HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    class HTTPClientSpy : HttpClient {
        var requestedUrls = [URL]()
        var completions = [(Error)->Void]()
        
        func get(from url: URL, completion: @escaping (Error) -> Void) {
            self.completions.append(completion)
            self.requestedUrls.append(url)
        }
        
    }
}

