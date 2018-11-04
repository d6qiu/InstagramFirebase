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
    
    //The tab bar controller calls this method in response to the user tapping a tab bar item. You can use this method to dynamically decide whether a given tab should be made the active tab.
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        let index = viewControllers?.firstIndex(of: viewController)
        if index == 2 {
            
            let photoSelectorController = PhotoSelectorController(collectionViewLayout: UICollectionViewFlowLayout())
            
            let navController = UINavigationController(rootViewController: photoSelectorController)
            present(navController, animated: true, completion: nil)
            return false //selected controller will not be made active which means when tab on plus, it will not switch to  the plus tab, which is blackscreen, but remain on same screen
            //so plus tab will never be selected it will just present photoselector nav
        }
        
        return true //if true, switch to the selected tab
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //before self.delegate is nill
        self.delegate = self 
        //after self.delegate is self
        if Auth.auth().currentUser == nil { //means user not loged in
            //must wait for MainTabBarController to be setted up (setUpViewControllers will go first)in the UI, so use main.async to let main thread continue running, executing this task later by wait for everything in main thread to be done, else black screen
            DispatchQueue.main.async {
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController) // navController lives inside scope of async // the rootviewcontroller can not be a tabbar controller //login controller  now has a navigation controller that can be accessed in its class
                //print(Thread.current)
                //print(Thread.isMainThread)
                self.present(navController, animated: true, completion: nil) //this is in main thread originally as well
                return
            }
            
        }
        setUpViewControllers()
    }
    //this is in main thread as well
    func setUpViewControllers() {
        
        //home
        let homeNavController = templateNavController(unselectedImage: UIImage(named: "home_unselected")!, selectedImage: UIImage(named: "home_selected")!, rootViewController: HomeController(collectionViewLayout: UICollectionViewFlowLayout()) )
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
            item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0) //positive values cause inset/shrunk, also move it down 4, negative values outset/expand
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
