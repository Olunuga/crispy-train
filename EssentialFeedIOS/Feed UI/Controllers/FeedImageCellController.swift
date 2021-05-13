//
//  FeedImageCellController.swift
//  EssentialFeedIOS
//
//  Created by Mayowa Olunuga on 12/05/2021.
//

import UIKit
import EssentialFeed

protocol FeedImageCellControllerDelegate {
    func didCancelImageRequest()
    func didRequestImage()
}

public final class FeedImageCellController : FeedImageView {
    
    private var delegate : FeedImageCellControllerDelegate
    private lazy var cell = FeedImageCell()
    
    init(delegate : FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }
    
    func preLoad(){
        delegate.didRequestImage()
    }
    
    func cancelLoad() {
        delegate.didCancelImageRequest()
    }
    
    func view() -> UITableViewCell {
        delegate.didRequestImage()
        return cell
    }
    
    
    func display(_ model: FeedImageViewData<UIImage>) {
        cell.locationContainer.isHidden = !model.hasLocation
        cell.locationLabel.text = model.location
        cell.descriptionLabel.text = model.description
        cell.feedImageView.image = model.image
        cell.feedImageContainer.isShimmering = model.isLoading
        cell.feedImageRetryButton.isHidden = !model.shouldRetry
        cell.onRetry = delegate.didRequestImage
    }
}
