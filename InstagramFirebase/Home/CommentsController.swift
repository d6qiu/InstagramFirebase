//
//  CommentsController.swift
//  InstagramFirebase
//
//  Created by wenlong qiu on 11/17/18.
//  Copyright © 2018 wenlong qiu. All rights reserved.
//

import UIKit
import Firebase
class CommentsController: UICollectionViewController, UICollectionViewDelegateFlowLayout, CommentInputAccessoryViewDelegate{ //collection view set collectionview delegate to self/conllectionviewcontroller, flowlayout delegate = colllection view's delegate
    
    var post: Post? //set in homepostcell
    
    let cellId = "cellId"
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive //drag = dimiss halfway pull up cancel dismiss
        //collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0) //expand collectionview content inset by 50 bottom/down 50
        //collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0) //the scroll slider on the right
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: cellId)
        
        fetchComments()
    }
    
    var comments = [Comment]()
    fileprivate func fetchComments() {
        guard let postId = post?.id else {return}
        let ref = Database.database().reference().child("comments").child(postId)
        ref.observe(.childAdded, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            
            guard let uid = dictionary["uid"] as? String else {return}
            
            Database.fetchUserWithUID(uid: uid, completion: { (user) in
                let comment = Comment(user: user, dictionary: dictionary)
                
                self.comments.append(comment)
                self.collectionView.reloadData()
            })
            
            
            
        }) { (err) in
            print("failed to fetch comments ", err)
        }
        
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CommentCell
        
        cell.comment = comments[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = CommentCell(frame: frame)
        dummyCell.comment = comments[indexPath.item]
        dummyCell.layoutIfNeeded() //force layout subviews immediately, update all contraints, layout the username and comment text with anchor constraint
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        
        
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize) //Returns the optimal size of the view based on its current constraints, but no constraintssize to base on if layoutifneeded is not called
        let height = max(40 + 8 + 8, estimatedSize.height)// 4o + 8 is the imageview.height + padding from cell's topanchor, extra 8 to balance it for bottom, so makes it at least 
        
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    //since viewwillappear will execute muti but viewdidload only once, read comment of viewillappear below, actions that could potentially make the view appear will trigger this method
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    //will disappear does not mean definitely disappear, e.g sliding controller embed in nav controll will trigger viewWillDisappear but user can always change their mind and stop the sliding
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated) //run the necessary code from super
        tabBarController?.tabBar.isHidden = false
    }
    
    //cuz lazy var instatiate after viewdidload, so has access to controller' properties
    lazy var containerView: CommentInputAccessoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50) //width ignored since has to be same as keyboard width
        let commentInputAccessoryView = CommentInputAccessoryView(frame: frame)
        commentInputAccessoryView.delegate = self
        
        
        return commentInputAccessoryView

    }()
    
    func didSubmit(for comment: String) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let postId = post?.id ?? ""
        let values = ["text": comment, "creationDate": Date().timeIntervalSince1970, "uid": uid] as [String: Any]
        Database.database().reference().child("comments").child(postId).childByAutoId().updateChildValues(values) { (err, ref) in
            if let err = err {
                print("failed to insert comment", err)
                return
            }
            print("succesfully inserted comment")
            
            self.containerView.clearCommentTextField()
        }
        
        
    }
    
    
    //keyboard does not include the textfield and the send button, those are implemented by you via this.
    override var inputAccessoryView: UIView? {
        get { //getter that gets inputAccesory view
            return containerView
        }
    }
    
    //whenever user interact with ui element, that element become first responder, canBecomefirstresponder lets inputaccessoryview can become first responder, view is the first responder, then user tap accessory view then accesroy view become first responder, but if you set canbecomefirst reponder return false, accessroyr view wont show up
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    
}
