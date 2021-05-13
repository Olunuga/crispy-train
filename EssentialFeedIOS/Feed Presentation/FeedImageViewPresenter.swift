//
//  FeedImageViewPresenter.swift
//  EssentialFeedIOS
//
//  Created by Mayowa Olunuga on 13/05/2021.
//

import Foundation
import EssentialFeed

protocol FeedImageView {
    associatedtype Image
    func display(_ model : FeedImageViewData<Image>)
}

struct FeedImageViewData<Image> {
    let description : String?
    let location : String?
    let image : Image?
    let isLoading : Bool
    let shouldRetry : Bool
    var hasLocation : Bool { location != nil}
}

class FeedImageViewPresenter<View : FeedImageView, Image> where View.Image == Image {
    private let view : View
    private let imageTransformer: (Data) -> Image?
    private struct InvalidImageDataError: Error {}
    
    internal init(view : View, imageTransformer :  @escaping ((Data) -> Image?)){
        self.view = view
        self.imageTransformer = imageTransformer
    }

    
    func didStartLoadingImageData(for model : FeedImage){
        view.display(FeedImageViewData(description: model.description,
                                       location: model.location,
                                       image: nil,
                                       isLoading : true,
                                       shouldRetry: false))
    }
    
    
    func didFinishLoadingImageData(with data : Data, for model: FeedImage){
        guard let image = imageTransformer(data) else {
            return didFinishLoadingData(with: InvalidImageDataError(), for: model)
        }
        
        view.display(FeedImageViewData(description: model.description,
                                       location: model.location,
                                       image: image,
                                       isLoading: false,
                                       shouldRetry: false))
    }
    
    func didFinishLoadingData(with error : Error, for model : FeedImage){
        view.display(FeedImageViewData(description: model.description,
                                       location: model.location,
                                       image: nil,
                                       isLoading: false,
                                       shouldRetry: true)
        )
    }
 
}
