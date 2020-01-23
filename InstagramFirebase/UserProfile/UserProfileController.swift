//
//  UserProfileController.swift
//  InstagramFirebase
//
//  Created by wenlong qiu on 10/13/18.
//  Copyright © 2018 wenlong qiu. All rights reserved.
//

import UIKit
import Firebase

//comand space click UICollectionViewDelegateFlowLayout to see protocol methods, or just google
class UserProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UserProfileHeaderDelegate {
    
    let cellId = "cellId"
    
    var userId: String?
    
    var isGridView = true //default is grid view
    
    let homePostCellId = "homePostCellId"
    
    func didChangeToGridView() {
        isGridView = true
        collectionView.reloadData() //calls cell methods again to display the right ones
    }
    
    func didChangeToListView() {
        isGridView = false
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //only observer, ie this class can observe notificaition
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: SharePhotoController.updateFeedNotificationName, object: nil)
        //collectionView.delegate = self //collectionView.delegate is already self, maybe only controllers need to set delegate = self, UICollectionViewController simply sets itself as the delegate of the collection view it owns
        
        collectionView?.backgroundColor = .white
        //uid is nil, call again when reload
        
        
        //need this else cuz no cell with identifier "headerId", whenever use deque think register and return number of cell or size of the supplementary view
        collectionView.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerId")
        collectionView.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(HomePostCell.self, forCellWithReuseIdentifier: homePostCellId)
        
        setUpLogOutButton()
        fetchUser() //command click into a function will get you there to the function
        //fetchPosts()
        //fetchOrderPosts() //.observe(.childAdded will observe future posts being uploaded to database
        
    }
    @objc func handleUpdateFeed() {
        handleRefresh()
    }
    
    @objc func handleRefresh() {
        
        posts.removeAll()
        isFinishedPaging = false
        paginatePosts()
        //fetchAllPosts()
    }
    
    var isFinishedPaging = false
    var posts = [Post]()
    
    fileprivate func paginatePosts() {
        guard let uid = self.user?.uid else {return}
        //each child is a dictionary, has value, and it's name as key
        let ref = Database.database().reference().child("posts").child(uid)
        
        //queryOrderedbykey dont sort the keys, just goes down keys as date added to the database
        //var query = ref.queryOrderedByKey()
        //print(query)
        var query = ref.queryOrdered(byChild: "creationDate") //sorted by the specific attribute/value of the child, childnode is autoid, creationDate is a key of autoid's value
        if posts.count > 0 { //if not first iteration of the query four posts at each step
            let value = posts.last?.creationDate.timeIntervalSince1970 //posts.last is the oldest post out of the four posts. oldest, older, recent, most recent, but post array is reveresed remember? so oldest = last
            query = query.queryEnding(atValue: value) //make query limit to less than or equal to value, which are only the posts with creation time older than value
            //query = query.queryStarting(atValue: value)
        }
        
        //queryordered base on creationDate, last 4 element ending at value
        //if first round, just last 4 on creationDate
        query.queryLimited(toLast: 4).observeSingleEvent(of: .value, with: { (snapshot) in //fetch 4 posts at one time, in order of creation date
            //snapshot.key is uid, snapshot.children is bunch of autoid/postid nodes, so allobjects = [postid : postinfodictionary] allojects is type [any], allobjects are bunch of autoid nodes
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return} //want array of snapshot children, which is just value of the snapshot
            //reverse array of snapshots of [autoid: postfo]posts that the child(uid)
            allObjects.reverse()
            
            if allObjects.count < 4 { //if less than 4 , out of elements to page
                self.isFinishedPaging = true
            }
            
            if self.posts.count > 0 && allObjects.count > 0 { //posts.count = 0 at first iteration
                allObjects.removeFirst() //the first one of second paging is repeated because queryEnding(equal to value) cause the repeat
            }
            
            guard let user = self.user else {return}
            
            //snapshot here is different than the above one , snapshot is each child of the above one
            allObjects.forEach({ (snapshot) in //for loop to iterate each element/autoid child
                //snapshot.key is post's autoid, so allObjects is arrray of [autoid: postinfoDictionary]
                guard let dictionary = snapshot.value as? [String: Any] else {return}
                var post = Post(user: user, dictionary: dictionary)
                post.id = snapshot.key //snapshot.key is autoid for each post, snapshot value is a dictioanrhy of attributes posts
                self.posts.append(post)
            })

            self.collectionView.reloadData()
        }) { (err) in
            print("failed to fetch paginateposts", err)
        }
    }
    
    
    fileprivate func fetchOrderPosts() {
        guard let uid = self.user?.uid else {return}
        let ref = Database.database().reference().child("posts").child(uid)
        //observe data added in order unlike observeSingleEvent
        //if data event type is .value, then snapshot is current database being referenced, if .childadded, then snapshot is its child
        //child -> auto id 's value is dictionary has key creationDate, child key is just key of the dictionary of child
        ref.queryOrdered(byChild: "creationDate").observe(.childAdded, with: { (snapshot) in //snapshot return the value of the child, the block is executed for each child in this database, if .value then block executed once and snapshot return value of this database
            
            guard let dictionary = snapshot.value as? [String: Any] else {return} //as will prompt error because might fail
            
            guard let user = self.user else {return}
            let post = Post(user: user, dictionary: dictionary)
            
            //put the newest post on first index 
            self.posts.insert(post, at: 0) //array .insert will insert at index, to the left of already exist element and push everything back
            
            self.collectionView.reloadData()
            
        }) { (err) in
            print("failed to get snapshot of ordered post just shared data", err)
        }
    }
    
    
    
    //fetch unordered poosts
//    fileprivate func fetchPosts() {
//        guard let uid = Auth.auth().currentUser?.uid else {return}
//        let ref = Database.database().reference().child("posts").child(uid)
//        //if data event type is .value, then snapshot is value of ref/current database
//        ref.observeSingleEvent(of: .value, with: { (snapshot) in
//
//            guard let dictionaries = snapshot.value as? [String: Any] else {return} //snape.value is a dicionary of autoid : any
//            dictionaries.forEach({ (key, value) in
//                //print("key \(key) value \(value)")
//
//                guard let dictionary = value as? [String: Any] else {return}
//
//                let dummyUser = User(dictionary: ["username": "me"])
//                let post = Post(user: dummyUser, dictionary: dictionary)
//                self.posts.append(post)
//
//            })
//            self.collectionView.reloadData()
//
//
//        }) { (err) in
//            print("Failed to fetch posts", err)
//        }
//    }
    
    
    
    
    
    fileprivate func setUpLogOutButton() { //.alwaysOriginal prevent system treating it as template which is that it will be filled with color blue
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "gear")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogOut))
    }
    
    @objc func handleLogOut() {
        //get rid of title and message of alertController and only keep the actions
        let alertController = UIAlertController(title: nil, message:  nil, preferredStyle: .actionSheet)
        
        //.destructive makes title red
        alertController.addAction(UIAlertAction(title: "Log Uut", style: .destructive, handler: { (_) in //if you dont need the returned parameter, just under score it
            //gonna need a reference to the logincontroller here
            do {
                try Auth.auth().signOut() //signout doesnt really reload the UI
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController) //navController is just a stack for you to push new viewcontrollers
                self.present(navController, animated: true, completion: nil)
            } catch {
                
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil)) //.cancel alreay cancels the alertController for you
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - collectionViewdatasource methods == give me something
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == self.posts.count - 1  && !isFinishedPaging { //if last post in the array
            paginatePosts()
        }
        
        
        if isGridView == true {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfilePhotoCell
            cell.post = posts[indexPath.item] //didset upon creation
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homePostCellId, for: indexPath) as! HomePostCell
            cell.post = posts[indexPath.item]
            return cell
        }
    }
    //MARK: - collectionviewflowlayout delegate methods
    //nextTo spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    //nextline/row spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isGridView == true {
            let width = (view.frame.width - 2) / 3 //-2 pixels from the nextTo spacings, otherwise since 3 * cellItem will exceed view.frame.width, flowlayout will automatically put the next cell in the next row
            return CGSize(width: width, height: width)
        } else {
            var height: CGFloat = 40 + 8 + 8 // userprofileimage.height + padding top + photoimageView padding top
            height += view.frame.width
            height += 50 //bottom context buttons
            height += 80 //caption space, change it to whatever u want, since caption label is the lowest block of ui anchored to view's bottom anchor (the above ones are kinda fixed), change this will make caption label automatic stretch
            return CGSize(width: view.frame.width, height: height) //so imageView will be a square
        }
    }
    
    //called once when initialize collectionView
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    //called once when initialize collectionView
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        //triggers init of userProfileHeader 
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! UserProfileHeader
        header.user = self.user
        header.delegate = self //userprofileheader has the delegate property
        
        return header
    }
    
    
    
    var user: User?
    fileprivate func fetchUser() {
        //when userId is not set by UserSearchController, uid = currentuser.uid
        let uid = userId ?? (Auth.auth().currentUser?.uid ?? "") //another way to unwrap to get rid of compile errors
        
        //guard let uid = Auth.auth().currentUser?.uid else {return}
        
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.user = user
            
            self.navigationItem.title = self.user?.username
            
            //self.collectionView.reloadData() //commented this out why??? could be reason for something to break here
            
            self.paginatePosts()
            //self.fetchOrderPosts() //.observe(.childAdded will observe future posts being uploaded to database
        }
        
    }
    
}
