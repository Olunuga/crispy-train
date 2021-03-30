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
        
        expect(sut, toCompleteWithResult: .failure(.connectivity), when: {
            let error = NSError(domain: "Test", code: 0, userInfo: nil)
            client.complete(with : error)
        })
        
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse(){
        //arrange
        let (sut, client) = MakeSUT()
        
        let samples  = [199, 201, 300, 400, 500]
        samples.enumerated().forEach{
            index, code  in
            expect(sut, toCompleteWithResult: .failure(.invalidData), when: {
                client.complete(withStatusCode : code, at: index )
            })
        }
        
        
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJson(){
        //arrange
        let (sut, client) = MakeSUT()
        
        expect(sut, toCompleteWithResult: .failure(.invalidData), when: {
            let invalidJSON = Data("Invalid Json".utf8)
            client.complete(withStatusCode : 200, data :invalidJSON)
        })
    }
    
    
    func test_load_deliversNoItemOn200HTTPResponseWithEmptyJson(){
        //arrange
        let (sut, client) = MakeSUT()
        
        expect(sut, toCompleteWithResult: .success([]), when: {
            let emptyListJSON = Data("{\"items\":[]}".utf8)
            client.complete(withStatusCode : 200, data: emptyListJSON)
            
        })
    }
    
    func test_load_deliversItemOn200HTTPResponseJsonItems(){
        //arrange
        let (sut, client) = MakeSUT()
        
        let item1 = makeItem(id: UUID(), description: nil, location: nil, imageURL:  URL(string: "http://a-url.com")!)
        
        let item2 = makeItem(id: UUID(), description: "a-description", location: "a-location", imageURL:  URL(string: "http://a-url.com")!)
        
      
        let items = [item1.model, item2.model]
        
        expect(sut, toCompleteWithResult: .success(items), when: {
            let json = makeItemsJSON([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: json)
        })
    }
    
    
    
    //Mark: Helpers
   private func MakeSUT(url : URL = URL(string: "some-given-url")!)->(sut : RemoteFeedLoader, client : HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func makeItem(id : UUID, description : String?, location : String?, imageURL : URL)-> (model : FeedItem, json : [String : Any]) {
        let item = FeedItem(id: id, description: description, location: location, imageUrl: imageURL)
        let json = [
            "id": id.uuidString,
            "description" : description,
            "location": location,
            "image": imageURL.absoluteString
        ].compactMapValues{$0}
        
        return (item, json)
    }
    
    
    private func makeItemsJSON( _ items :  [[String:Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    
   private func expect(_ sut : RemoteFeedLoader, toCompleteWithResult  result: RemoteFeedLoader.Result, when action : () -> Void, file : StaticString = #filePath, line : UInt = #line ) {
        //act
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load {capturedResults.append($0) }
        action()
        XCTAssertEqual(capturedResults, [result],file : file, line : line)
    }
    
    
    typealias completionType = (HttpClientResult)->Void
    class HTTPClientSpy : HttpClient {
        private var messages = [(url : URL, completion : completionType)]()
        var requestedUrls : [URL] {
            messages.map{$0.url}
        }
        
        func get(from url: URL, completion: @escaping completionType) {
            messages.append((url,completion))
        }
        
        func complete(with error : Error, index : Int = 0){
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code : Int,data : Data = Data(), at index : Int = 0){
            let result = HTTPURLResponse(url: requestedUrls[index], statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success(data ,result))
        }
        
        
    }
}

