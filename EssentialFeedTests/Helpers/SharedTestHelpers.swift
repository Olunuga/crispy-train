//
//  FeedLoaderTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Mayowa Olunuga on 17/04/2021.
//

import Foundation

public func anyNSError()-> NSError {NSError(domain: "Any error", code: NSURLErrorUnknown, userInfo: ["":""])}

public func anyURL() -> URL {URL(string: "http://any-url.com")!}
