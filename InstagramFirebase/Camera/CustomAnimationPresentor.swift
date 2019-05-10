//
//  CustomAnimationPresentor.swift
//  InstagramFirebase
//
//  Created by wenlong qiu on 11/16/18.
//  Copyright © 2018 wenlong qiu. All rights reserved.
//

import UIKit
class CustomAnimationPresentor: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    //UIKit calls this method when presenting or dismissing a view controller  but since this class is a presentor
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        guard let fromView = transitionContext.view(forKey: .from) else {return} //get reference of homecontroller's view, frame's default is 0,0, width, height?
        
        guard let toView = transitionContext.view(forKey: .to) else {return} //get reference of cameracontroller's view 
        containerView.addSubview(toView)
        
        //in case of camera controller, camera controller is toview, when presented, set start frame then animation
        let startingFrame = CGRect(x: -toView.frame.width, y: 0, width: toView.frame.width, height: toView.frame.height)
        toView.frame = startingFrame
        //everything shrifts right
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            //destionations
            toView.frame = CGRect(x: 0, y: 0, width: toView.frame.width, height: toView.frame.height)
            
            fromView.frame = CGRect(x: fromView.frame.width, y: 0, width: fromView.frame.width, height: fromView.frame.height)
            
        }) { (_) in
            transitionContext.completeTransition(true) //must call this tot notify system animaiton is done
        }
        
    }
}
