//
//  FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Mayowa Olunuga on 20/04/2021.
//

import Foundation

public protocol FeedStoreSpecs {
     func test_retrieve_deliversEmptyOnEmptyCache()
     func test_retrieve_hasNoSideEffectOnEmptyCache()
     func test_retrieve_deliversFoundValuesOnNonEmptyCache()
     func test_retrieve_hasNoSideEffectOnNonEmptyCache()
   
     func test_insert_deliversNoErrorOnEmptyCache()
     func test_insert_overridesPreviouslyCachedValue()
     func test_insert_deliversNoErrorOnNonEmptyCache()
    
     func test_delete_deliversNoErrorOnEmptyCache()
     func test_delete_hasNoSideEffectOnEmptyCache()
     func test_delete_deliversNoErrorOnNonEmptyCache()
     func test_delete_emptiesPreviouslyInsertedCache()
     
     func test_storeSideEffects_runSerially()
}


protocol FailableRetreiveFeedStoreSpecs : FeedStoreSpecs {
    func test_retrieve_deliversFailureOnRetrievalError()
    func test_retrieve_hasNoSideEffectOnFailure()
}

protocol FailableInsertFeedStoreSpecs : FeedStoreSpecs {
    func test_insert_deliversErrorOnInsertionError()
    func test_insert_hasNoSideEffectInsertionError()
}

protocol FailableDeleteFeedStoreSpecs : FeedStoreSpecs{
    func test_delete_deliversErrorOnDeletionError()
    func test_delete_hasNoSideEffectOnDeletionError()
}


typealias FailableFeedStoreSpecs = FailableInsertFeedStoreSpecs & FailableRetreiveFeedStoreSpecs & FailableDeleteFeedStoreSpecs
