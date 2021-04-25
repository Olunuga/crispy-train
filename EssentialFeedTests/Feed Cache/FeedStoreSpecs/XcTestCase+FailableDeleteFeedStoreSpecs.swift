//
//  XcTestCase+FailableDeleteFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Mayowa Olunuga on 25/04/2021.
//

import XCTest
import EssentialFeed

extension FailableDeleteFeedStoreSpecs where Self : XCTestCase {
    func assertThatDeleteDeliversErrorOnDeletionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            let deletionError = deleteCache(from: sut)
            
            XCTAssertNotNil(deletionError, "Expected cache deletion to fail", file: file, line: line)
        }
        
        func assertThatDeleteHasNoSideEffectsOnDeletionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            deleteCache(from: sut)
            
            expect(sut, toRetrieve: .empty, file: file, line: line)
        }
}
