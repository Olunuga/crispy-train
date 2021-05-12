//
//  UIRefreshControl+TestHelpers.swift
//  EssentialFeedIOSTests
//
//  Created by Mayowa Olunuga on 12/05/2021.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh(){
        allTargets.forEach{ target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach{
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
