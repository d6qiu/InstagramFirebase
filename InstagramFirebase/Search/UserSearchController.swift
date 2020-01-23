//
//  UserSearchController.swift
//  InstagramFirebase
//
//  Created by wenlong qiu on 11/4/18.
//  Copyright © 2018 wenlong qiu. All rights reserved.
//

import UIKit
import Firebase

class UserSearchController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate{
    
    lazy var searchBar: UISearchBar = { //lazy var instead of let is required because self/usersearchcontroller must be instantiated before this variable is defined, else err: Cannot assign value of type '(UserSearchController) -> () -> (UserSearchController)' to type 'UISearchBarDelegate?' when set sb.delegate = self at line 20
        let sb = UISearchBar()
        sb.placeholder = "Enter username"
        sb.barTintColor = .gray //deosnt do anything
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230) //get the textfeild contained in this class
        
        sb.delegate = self //make sure self exist before accessing it by making searchbar a lazy vairable
        
        return sb
    }()
    
    //delegate is that an event happened, calls the method of the delegate class that shits happened, repond by running the block of code. delegate is part of the company, shoulding off functions to the delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            filteredUsers = users
        } else {
            filteredUsers = users.filter { (user) -> Bool in //filter takes in a function that returns a bool as parameter that determines whether to keep it in the result collection
                return user.username.lowercased().contains(searchText.lowercased())
            }
        }
        collectionView.reloadData()
    }
    
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        
        navigationController?.navigationBar.addSubview(searchBar) //add searchbar to the navigation bar
        
        let navBar = navigationController?.navigationBar
        
        //anchor searchbar in the navBar
        searchBar.anchor(top: navBar?.topAnchor, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: navBar?.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: -8, width: 0, height: 0)
        
        collectionView.register(UserSearchCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView.alwaysBounceVertical = true //bounces when scroll down or up even not enough cells to exceed screen space
        collectionView.keyboardDismissMode = .onDrag //keyboard dismiss whenever drag on view
        
        fetchUsers()
    }
    
    //calls after viewdid load, but will load multiple times everything view shows, viewdidload just load into memory
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.isHidden = false
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        searchBar.isHidden = true
        searchBar.resignFirstResponder() //dimiss keyboard when push into another view
        
        
        let user = filteredUsers[indexPath.item]
        
        let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileController.userId = user.uid
        
        navigationController?.pushViewController(userProfileController, animated: true)
        
    }
    
    
    
    var filteredUsers = [User]()
    var users = [User]() //wihtout self user
    
    
    fileprivate func fetchUsers() {
        
        let ref = Database.database().reference().child("users")
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionaries = snapshot.value as? [String: Any] else {return}
            
            dictionaries.forEach({ (key, value) in
                
                if key == Auth.auth().currentUser?.uid { //omit myself from search result
                    return
                }
                
                guard let userDictionary = value as? [String: Any] else {return}
                let user = User(uid: key, dictionary: userDictionary)
                self.users.append(user)
                
            })
            self.users.sort(by: { (u1, u2) -> Bool in
                //return u1.username < u2.username works too
                return u1.username.compare(u2.username) == .orderedAscending
            })
            self.filteredUsers = self.users
            self.collectionView.reloadData()
            
        }) { (err) in
            print("failed to fetch users in search bar ", err)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserSearchCell
        
        cell.user = filteredUsers[indexPath.item]
        
        return cell
    }
    
    //collection view shows rows and not grid because cgsize width is set to view.frame.width 
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 66) //profileimage is 50 + 8 + 8 for padding
    }
}
