//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by Mayowa Olunuga on 30/03/2021.
//

import XCTest
import EssentialFeed


class RemoteFeedLoaderTest : XCTestCase {
    
    func test_load_not_called(){
        //arrange
        let (_, client) = MakeSUT()
    
        //assert
        XCTAssertNil(client.requestedUrl)
    }
    
    
    func test_load_is_called(){
        //arrange
        let tUrl = URL(string: "a-given-url.com")!
        let (sut, client) = MakeSUT(url: tUrl)
    
        //act
        sut.load()
        
        //assert
        XCTAssert(client.requestedUrl == tUrl)
    }
    
    
    
    //Mark: Helpers
    func MakeSUT(url : URL = URL(string: "some-given-url")!)->(sut : RemoteFeedLoader, client : HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    class HTTPClientSpy : HttpClient {
        var requestedUrl : URL?
        func get(from url: URL) {
            self.requestedUrl = url
        }
    }
}

