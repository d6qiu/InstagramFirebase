//
//  HomeController.swift
//  InstagramFirebase
//
//  Created by wenlong qiu on 11/3/18.
//  Copyright © 2018 wenlong qiu. All rights reserved.
//

import UIKit
import Firebase


class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout, HomePostCellDelegate{
    let cellId = "cellId"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add notification observer to observe for notificaition name updatefeedm, self.handupdatefeed when observed 
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: SharePhotoController.updateFeedNotificationName, object: nil)
        
        
        collectionView.backgroundColor = .white
    
        collectionView.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged) //touchdragging trigger refreshcontroll and its action, user drag down, finish animation, start fetching means user stopped dragging, the refresh activates when user finish dragging., after user finish dragging, handleRefresh() gets called.
        collectionView.refreshControl = refreshControl
        
        setupNavigationItems() //outlets before load model
        
        fetchAllPosts()
    }
    
    @objc func handleUpdateFeed() {
        handleRefresh()
    }
    
    @objc func handleRefresh() {
        
        posts.removeAll()
        
        fetchAllPosts()
    }
    
    fileprivate func fetchAllPosts() {
        fetchPosts() //fetch self posts
        fetchFollowingUserIds() //fetch following posts
        DispatchQueue.main.async {
            //self.collectionView.reloadData()
        }
    }
    
    
    fileprivate func fetchFollowingUserIds() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Database.database().reference().child("following").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            //following dictionary [id: 1] //unfollow will just remove the child
            guard let userIdsDictionary = snapshot.value as? [String: Any] else {return}
            userIdsDictionary.forEach({ (key, value) in
                Database.fetchUserWithUID(uid: key, completion: { (user) in
                    self.fetchPostsWithUser(user: user)
                })
            })
        }) { (err) in
            print("failed to fetch followed user ids", err)
        }
        
    }
    
    

    var posts = [Post]() //cache
    fileprivate func fetchPosts() { //calls static method to fetch user profile and define completion handler to fetch user posts
        guard let uid = Auth.auth().currentUser?.uid else {return} //returns when ikf user not logged in ie at log in screen
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.fetchPostsWithUser(user: user)
            
        }
    }
    
    fileprivate func fetchPostsWithUser(user: User) { //fetch that user's posts

        let ref = Database.database().reference().child("posts").child(user.uid) //fetching posts with the corresponding user and not the current user
        //if data event type is .value, then snapshot is value of ref/current database
        ref.observeSingleEvent(of: .value, with: { (snapshot) in //snapshot is the child(user.uid) itself. snapshot.key is userid
            
            self.collectionView.refreshControl?.endRefreshing() //end the refreshing animation but only after user stopped dragging, user have to stop dragging to triggerr the refreshing, ie get to this line
            //snapshot.key is user id
            guard let dictionaries = snapshot.value as? [String: Any] else {return} //snape.value is a dicionary of autoid : any //auto id is id for eaach posts
            
            dictionaries.forEach({ (key, value) in //for each post of this user
                //print("key \(key) value \(value)")
                //key is post id/name
                guard let dictionary = value as? [String: Any] else {return} //post info
                
                var post = Post(user: user, dictionary: dictionary) //cache posts
                post.id = key
                
                guard let uid = Auth.auth().currentUser?.uid else {return} //uid is the key of dictionary of child(postid) value
                //
                Database.database().reference().child("likes").child(key).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let value = snapshot.value as? Int, value == 1 {
                        post.hasLiked = true
                    } else {
                        post.hasLiked = false
                    }
                    self.posts.append(post)
                    
                    self.posts.sort(by: { (p1, p2) -> Bool in
                        return p1.creationDate.compare(p2.creationDate) == .orderedDescending //recent goes to left, bigger value of creationDate goes to left
                    })
                    
                   self.collectionView.reloadData() //whenever in class model changes
                }, withCancel: { (err) in
                    print("failed to fetch like status for posts:", err)
                })
                
                //DispatchQueue.main.async {
                 //   self.collectionView.reloadData()
                //}
            })
            
            
            
        }) { (err) in
            print("Failed to fetch posts", err)
        }
    }
    fileprivate func setupNavigationItems() {
        navigationItem.titleView = UIImageView(image: UIImage(named: "logo2"))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "camera3")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleCamera))
    }
    
    @objc func handleCamera() {
        let cameraController = CameraController()
        present(cameraController, animated: true, completion: nil)
    }
    //if method not show up means not conform to protocol, sizeforitemat determines size of ui elements inside it because they stretches
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 40 + 8 + 8 // userprofileimage.height + padding top + photoimageView padding top
        height += view.frame.width
        height += 50 //bottom context buttons
        height += 80 //caption space ,change it to whatever u want, since caption label is the lowest block of ui anchored to view's bottom anchor (the above ones are kinda fixed), change this will make caption label automatic stretch
        return CGSize(width: view.frame.width, height: height) //so imageView will be a square
        
    }
    
    //executate after viewdidload but not after running completion clousres in viewdidload
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    //after viewdidload and everytime dequeue reusable cell ie scrolling, if only this is called, that means user scrolled.
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomePostCell //use force because you know for sure this is the type, when u are smarter than system
        if posts.count > 0 { //need this because when user drag down to refresh (remove all posts and refetch them), it also triggers dequeue reusable as unintended effect and will run this line without runing return posts.count first, so the below line is ran when posts are removed , so posts.count = 0, and will give a indexoutofbounds exception, handlerefresh has completion handlers, so dequeResuable is ran during this moment before the completion handler get to cache posts.
            cell.post = posts[indexPath.item] //indexpath is just the path, item is the actual value/index
        }
        
        cell.delegate = self //so cell gets a reference of self/homecontroller, but homecontroller has no ref to cell, so no retain cycle
        
        
        return cell
    }
    
    
    func didTapComment(post: Post) {
        //cannet convert type to object means missing parenthese at the end
        let commentsController = CommentsController(collectionViewLayout: UICollectionViewFlowLayout()) //has to specify layout cuz its a collectionview
        
        commentsController.post = post
        
        navigationController?.pushViewController(commentsController, animated: true)
    }
    
    func didLike(for cell: HomePostCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {return}
        var post = posts[indexPath.item] //gets a copy of struct post since struct is value type
        guard let postId = post.id else {return}
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let values = [uid: post.hasLiked == true ? 0 : 1]
        //need child(postId) so when fetch likes you know which post to for
        Database.database().reference().child("likes").child(postId).updateChildValues(values) { (err, ref) in //updatechildvalues updates not replace
            if let err = err {
                print("failed to like post ", err )
                return
            }
            
            print("succesfullu liked the post")
            
            post.hasLiked = !post.hasLiked
            
            self.posts[indexPath.item] = post //since struct is value type, the line above var post = posts[indexPath.item] //gets a copy of struct post since struct is value type
            self.collectionView.reloadItems(at: [indexPath])
        }
        
    }
    
    
}
