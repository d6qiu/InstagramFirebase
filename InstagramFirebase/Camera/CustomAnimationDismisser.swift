//
//  CustomAnimationDismisser.swift
//  InstagramFirebase
//
//  Created by wenlong qiu on 11/16/18.
//  Copyright © 2018 wenlong qiu. All rights reserved.
//

import UIKit

class CustomAnimationDismisser: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    //UIKit calls this method when presenting or dismissing a view controller since this class is a dimisser
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        guard let fromView = transitionContext.view(forKey: .from) else {return}
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            <#code#>
        }) { (_) in
            <#code#>
        }
        
    }
}
