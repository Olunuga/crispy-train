//
//  UIButton+TestHelpers.swift
//  EssentialFeedIOSTests
//
//  Created by Mayowa Olunuga on 12/05/2021.
//

import UIKit
 
extension UIButton {
    func simulateTap(){
        allTargets.forEach{ target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach{
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
