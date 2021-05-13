//
//  FeedImageViewModel.swift
//  EssentialFeedIOS
//
//  Created by Mayowa Olunuga on 12/05/2021.
//

import EssentialFeed

private final class FeedImageViewModel<Image> {
    typealias Observable<T> = (T)->Void
    
    private var task : FeedImageDataLoaderTask?
    private var model : FeedImage
    private var imageLoader : FeedImageDataLoader
    private let imageTransformer : (Data) -> Image?
    
    init(model : FeedImage, imageLoader : FeedImageDataLoader, imageTransformer : @escaping (Data) -> Image?) {
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
    }
    
    var hasLocation : Bool  {model.location != nil}
    var location : String? {model.location}
    var description : String? {model.description}
    
    var onImageLoad : Observable<Image>?
    var onImageLoadingStateChange : Observable<Bool>?
    var onShouldRetryImageLoadStateChange : Observable<Bool>?
    
    func loadImageData(){
        onImageLoadingStateChange?(true)
        onShouldRetryImageLoadStateChange?(false)
        task = imageLoader.loadImageData(from : model.url) {[weak self] result in
            self?.handle(result)
        }
    }
    
    private func handle(_ result : FeedImageDataLoader.Result){
        if let image = (try? result.get()).flatMap(imageTransformer) {
            onImageLoad?(image)
        }else{
            onShouldRetryImageLoadStateChange?(true)
        }
        onImageLoadingStateChange?(false)
    }
    
    func preLoad(){
        self.task = self.imageLoader.loadImageData(from : self.model.url) {_ in }
    }
    
    func cancelLoad() {
        task?.cancel()
    }
}
