//
//  MainTabBarController.swift
//  InstagramFirebase
//
//  Created by wenlong qiu on 10/13/18.
//  Copyright © 2018 wenlong qiu. All rights reserved.
//

import UIKit
import Firebase
class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        let index = viewControllers?.firstIndex(of: viewController)
        if index == 2 {
            
            let photoSelectorController = PhotoSelectorController(collectionViewLayout: UICollectionViewFlowLayout())
            
            let navController = UINavigationController(rootViewController: photoSelectorController)
            present(navController, animated: true, completion: nil)
            return false //disable viewcontrollers being selected when tap on plus bar item
        }
        
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //before self.delegate is nill
        self.delegate = self 
        //after self.delegate is self
        
        if Auth.auth().currentUser == nil { //means user not loged in
            //must wait for MainTabBarController to be setted up in the UI, so use main.async
            DispatchQueue.main.async {
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController) // navController lives inside scope of async // the rootviewcontroller can not be a tabbar controller //login controller  now has a navigation controller that can be accessed in its class
                self.present(navController, animated: true, completion: nil)
                return
            }
            
        }
        
        setUpViewControllers()
    }
    
    func setUpViewControllers() {
        
        //home
        let homeNavController = templateNavController(unselectedImage: UIImage(named: "home_unselected")!, selectedImage: UIImage(named: "home_selected")!, rootViewController: UserProfileController(collectionViewLayout: UICollectionViewFlowLayout()) )
        //search
        let searchNavController = templateNavController(unselectedImage: UIImage(named: "search_unselected")!, selectedImage: UIImage(named: "search_selected")!)
        //plus
        let plusNavController = templateNavController(unselectedImage: UIImage(named: "plus_unselected")!, selectedImage: UIImage(named: "plus_unselected")!)
        //like
        let likeNavController = templateNavController(unselectedImage: UIImage(named: "like_unselected")!, selectedImage: UIImage(named: "like_selected")!)
        
        //user profile
        //supports horizontal and vertical scroll direction //grid
        let layout = UICollectionViewFlowLayout()
        let userProfileController = UserProfileController(collectionViewLayout: layout) //init collection view controller and specifies which layout
        //implement navigation bar on top
        let userProfileNavController = UINavigationController(rootViewController: userProfileController)
        
        userProfileNavController.tabBarItem.image = UIImage(named: "profile_unselected") //childof  tabbarcontoller .tobBaritem
        userProfileNavController.tabBarItem.selectedImage = UIImage(named: "profile_selected")
        
        tabBar.tintColor = .black //default tint color /outline color is blue
        viewControllers = [homeNavController, searchNavController, plusNavController, likeNavController, userProfileNavController, ]//adding navControllers as children of tabBarcontroller
        
        //modify tab bar item insets
        guard let items = tabBar.items else {return}
        
        for item in items {
            item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0) //positive values cause inset/shrunk, negative values outset/expand
        }
    }
    
    fileprivate func templateNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController { //gives a default rootViewController if nil parameter when call this function
        let viewController = rootViewController
        let navController = UINavigationController(rootViewController: viewController)
        
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        
        return navController
    }
}
