//
//  XCTTestCase+MemoryLeakTrackingHelper.swift
//  EssentialFeedTests
//
//  Created by Mayowa Olunuga on 01/04/2021.
//

import XCTest


public extension XCTestCase {
    func trackForMemoryLeak(_ instance : AnyObject, file : StaticString  = #filePath, line : UInt = #line){
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been de-allocated. Potential memory leak", file: file, line: line)
        }
    }
}
