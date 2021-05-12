//
//  FeedImageCellController.swift
//  EssentialFeedIOS
//
//  Created by Mayowa Olunuga on 12/05/2021.
//

import UIKit
import EssentialFeed

public final class FeedImageCellController {
    private var viewModel : FeedImageViewModel<UIImage>
    
    init(viewModel : FeedImageViewModel<UIImage>) {
        self.viewModel = viewModel
    }
    
    func preLoad(){
        viewModel.preLoad()
    }
    
    func cancelLoad() {
        viewModel.cancelLoad()
    }
    
    func view() -> UITableViewCell {
        let cell = bounded(FeedImageCell())
        viewModel.loadImageData()
        return cell
    }
    
    private func bounded(_ cell : FeedImageCell) -> FeedImageCell {
        cell.locationContainer.isHidden = !viewModel.hasLocation
        cell.locationLabel.text = viewModel.location
        cell.descriptionLabel.text = viewModel.description
        cell.onRetry = viewModel.loadImageData
        
        viewModel.onImageLoad = {[weak cell] image in
            cell?.feedImageView.image = image
        }
        
        viewModel.onImageLoadingStateChange = {[weak cell] isLoading in
            cell?.feedImageContainer.isShimmering = isLoading
        }
        
        viewModel.onShouldRetryImageLoadStateChange = {[weak cell] shouldRetry in
            cell?.feedImageRetryButton.isHidden = !shouldRetry
        }
        
        return cell
    }
    
    
}
