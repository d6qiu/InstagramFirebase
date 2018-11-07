//
//  HomeController.swift
//  InstagramFirebase
//
//  Created by wenlong qiu on 11/3/18.
//  Copyright © 2018 wenlong qiu. All rights reserved.
//

import UIKit
import Firebase


class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout{
    let cellId = "cellId"
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        
        collectionView.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
        
        setupNavigationItems()
        
        fetchPosts()
        
    }
    
    var posts = [Post]()
    fileprivate func fetchPosts() { //calls static method to fetch user profile and define completion handler to fetch user posts
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.fetchPostsWithUser(user: user)
        }
    }
    
    fileprivate func fetchPostsWithUser(user: User) { //fetch user's posts

        let ref = Database.database().reference().child("posts").child(user.uid) //fetching post with the corresponding user and not the current user
        //if data event type is .value, then snapshot is value of ref/current database
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionaries = snapshot.value as? [String: Any] else {return} //snape.value is a dicionary of autoid : any
            
            dictionaries.forEach({ (key, value) in
                //print("key \(key) value \(value)")
                
                guard let dictionary = value as? [String: Any] else {return}
                
                
                let post = Post(user: user, dictionary: dictionary)
                self.posts.append(post)
                
            })
            self.collectionView.reloadData()
            
            
        }) { (err) in
            print("Failed to fetch posts", err)
        }
    }
    fileprivate func setupNavigationItems() {
        navigationItem.titleView = UIImageView(image: UIImage(named: "logo2"))
    }
    //if method not show up means not conform to protocol
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 40 + 8 + 8 // username + padding top + imageView padding top
        height += view.frame.width
        height += 50 //bottom context buttons
        height += 80 //caption space 
        return CGSize(width: view.frame.width, height: height) //so imageView will be a square
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomePostCell //use force because you know for sure this is the type, when u are smarter than system
        
        cell.post = posts[indexPath.item]
        
        
        return cell
    }
    
    
}
