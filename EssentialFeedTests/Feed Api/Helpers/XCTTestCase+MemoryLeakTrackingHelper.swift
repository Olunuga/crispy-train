//
//  XCTTestCase+MemoryLeakTrackingHelper.swift
//  EssentialFeedTests
//
//  Created by Mayowa Olunuga on 01/04/2021.
//

import XCTest


extension XCTestCase {
    func trackForMemoryLeak(instance : AnyObject, file : StaticString , line : UInt){
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been de-allocated. Potential memory leak", file: file, line: line)
        }
    }
}
