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
        //addd target will not retain the target
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged) //touchdragging trigger refreshcontroll and its action
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
        fetchPosts()
        fetchFollowingUserIds()
    }
    
    
    fileprivate func fetchFollowingUserIds() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Database.database().reference().child("following").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            //following dictionary [id: 1] //unfollow will just remove the child
            guard let userIdsDictionary = snapshot.value as? [String: Any] else {return}
            userIdsDictionary.forEach({ (key, value) in
                //fetchuserwithuid takes escaping closure and this closure points to self so makes database strong reference to self increase ref count
                Database.fetchUserWithUID(uid: key, completion: { [weak self] (user) in
                    self?.fetchPostsWithUser(user: user)
                })
            })
        }) { (err) in
            print("failed to fetch followed user ids", err)
        }
        
    }
    
    

    var posts = [Post]()
    fileprivate func fetchPosts() { //calls static method to fetch user profile and define completion handler to fetch user posts
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Database.fetchUserWithUID(uid: uid) { [weak self](user) in
            self?.fetchPostsWithUser(user: user)
            
        }
    }
    
    fileprivate func fetchPostsWithUser(user: User) { //fetch that user's posts

        let ref = Database.database().reference().child("posts").child(user.uid) //fetching post with the corresponding user and not the current user
        //if data event type is .value, then snapshot is value of ref/current database
        ref.observeSingleEvent(of: .value, with: { [weak self](snapshot) in //snapshot is the child(user.uid) itself. snapshot.key is userid
            
            self?.collectionView.refreshControl?.endRefreshing() //end the refreshing animation but only after user stopped dragging
            //snapshot.key is user id
            guard let dictionaries = snapshot.value as? [String: Any] else {return} //snape.value is a dicionary of autoid : any //auto id is id for eaach posts
            
            dictionaries.forEach({ (key, value) in
                //print("key \(key) value \(value)")
                
                guard let dictionary = value as? [String: Any] else {return} //post info
                
                var post = Post(user: user, dictionary: dictionary)
                post.id = key
                
                guard let uid = Auth.auth().currentUser?.uid else {return} //uid is the key of dictionary of child(postid) value
                Database.database().reference().child("likes").child(key).child(uid).observeSingleEvent(of: .value, with: { [weak self](snapshot) in
                    if let value = snapshot.value as? Int, value == 1 {
                        post.hasLiked = true
                    } else {
                        post.hasLiked = false
                    }
                    self?.posts.append(post)
                    
                    self?.posts.sort(by: { (p1, p2) -> Bool in
                        return p1.creationDate.compare(p2.creationDate) == .orderedDescending //recent goes to left, bigger goes to left
                    })
                    
                    self?.collectionView.reloadData() //whenever in class model changes
                }, withCancel: { (err) in
                    print("failed to fetch like status for posts:", err)
                })
            
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
        
        cell.delegate = self //so cell gets a reference of self/homecontroller
        
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
        Database.database().reference().child("likes").child(postId).updateChildValues(values) { [weak self](err, ref) in
            if let err = err {
                print("failed to like post ", err )
                return
            }
            
            print("succesfullu liked the post")
            
            post.hasLiked = !post.hasLiked
            
            self?.posts[indexPath.item] = post //since struct is value type, the line above var post = posts[indexPath.item] //gets a copy of struct post since struct is value type
            self?.collectionView.reloadItems(at: [indexPath])
        }
        
    }
    
    
}
