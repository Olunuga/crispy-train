//
//  FeedImageCell+TestHelpers.swift
//  EssentialFeedIOSTests
//
//  Created by Mayowa Olunuga on 12/05/2021.
//

import UIKit
import EssentialFeedIOS

extension FeedImageCell {
    var isShowingLocation : Bool {
        return !locationContainer.isHidden
    }
    
    var isShowingRetryAction : Bool {
        return !feedImageRetryButton.isHidden
    }
    
    var locationText : String? {
        return locationLabel.text
    }
    
    var descriptionText : String? {
        return descriptionLabel.text
    }
    
    var isShowingLoadingIndicator : Bool {
        return feedImageContainer.isShimmering
    }
    
    var renderedImage : Data? {
       return feedImageView.image?.pngData()
    }
    
    func simulateRetryAction(){
        feedImageRetryButton.simulateTap()
    }
}
