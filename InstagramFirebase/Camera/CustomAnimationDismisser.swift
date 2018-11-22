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
        
        guard let fromView = transitionContext.view(forKey: .from) else {return} //get reference of camera controller's view
        
        guard let toView = transitionContext.view(forKey: .to) else {return} //get reference of home controller's view
        
        containerView.addSubview(toView) //must add homecontroller's view before doing the animation otherwise you wont see the toview during the animation, it will be black screen then the animation
        //after everything shrifts right in present animate object, then everything shrifts left
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            fromView.frame = CGRect(x: -fromView.frame.width, y: 0, width: fromView.frame.width, height: fromView.frame.height)
            
            toView.frame = CGRect(x: 0, y: 0, width: toView.frame.width, height: toView.frame.height)
            
        }) { (_) in
            transitionContext.completeTransition(true) //You must call this method after your animations have completed to notify the system that the transition animation is done. otherwise ui elements such as the dimissbutton wont work since still in transition
        }
        
    }
}
