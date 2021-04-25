//
//  XCTestCase+FailableRetrieveFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Mayowa Olunuga on 25/04/2021.
//

import XCTest
import EssentialFeed


extension FailableRetreiveFeedStoreSpecs where Self : XCTestCase {
    func assertThatRetrieveDeliversFailureOnRetrievalError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            expect(sut, toRetrieve: .failure(anyNSError()), file: file, line: line)
        }
        
        func assertThatRetrieveHasNoSideEffectsOnFailure(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            expect(sut, toRetrieveTwice: .failure(anyNSError()), file: file, line: line)
        }
}
