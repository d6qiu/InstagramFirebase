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
class UserProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //collectionView.delegate = self //collectionView.delegate is already self, maybe only controllers need to set delegate = self, UICollectionViewController simply sets itself as the delegate of the collection view it owns
        
        collectionView?.backgroundColor = .white
        //uid is nil, call again when reload
        navigationItem.title = Auth.auth().currentUser?.uid
        
        fetchUser() //command click into a function will get you there to the function 
        //need this else cuz no cell with identifier "headerId", whenever use deque think register and return number of cell or size of the supplementary view
        collectionView.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerId")
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        
        setUpLogOutButton()
        
    }
    
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
        return 7
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
        cell.backgroundColor = .purple
        return cell
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
        let width = (view.frame.width - 2) / 3 //-2 pixels from the nextTo spacings, otherwise since 3 * cellItem will exceed view.frame.width, flowlayout will automatically put the next cell in the next row
        return CGSize(width: width, height: width)
        
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
        
        return header
    }
    
    
    var user: User?
    fileprivate func fetchUser() {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        //observeSingleEvent means stop listening after one event, which means only does/retriece initial data from database, observe() does initial data and later changes.
        //uses dictionary to construct database, cast retrieved value back to dictionary
        //event triggered handler block called when at first retrive persisted data on firebase
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot.value ?? "")
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            
            self.user = User(dictionary: dictionary)
            
            self.navigationItem.title = self.user?.username
            
            self.collectionView.reloadData() //just reload data when observe event //triggers all the datasource and delegate methods
            
        }) { (err) in
            print("Failed to fetch user:", err)
        }
        
    }
    
}
//groups information, cleans code, //instead of fetching user profile image again from database, create a user struct, stores fetched database data inside, and send it header by header.user = self.user at line 31
struct User {
    let username: String
    let profileImageUrl: String
    
    init(dictionary: [String: Any]) {
        username = dictionary["username"] as? String ?? ""
        profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
    }
}
