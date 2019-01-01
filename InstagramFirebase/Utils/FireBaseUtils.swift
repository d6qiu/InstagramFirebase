//
//  FireBaseUtils.swift
//  InstagramFirebase
//
//  Created by wenlong qiu on 11/4/18.
//  Copyright © 2018 wenlong qiu. All rights reserved.
//

import Foundation
import Firebase

extension Database {
    //what to do with user, may use it or not 
    static func fetchUserWithUID(uid: String, completion: @escaping (User) -> ()) { //fetch user profile only and complete handler that does whatever you want
        //if make type user instead the block will not run, err would not even be printed out
        //observeSingleEvent means stop listening after one event, which means only does/retriece initial data from database, observe() does initial data and later changes.
        //uses dictionary to construct database, cast retrieved value back to dictionary
        //event triggered handler block called when at first retrive persisted data on firebase
        //The listener receives a FIRDataSnapshot that contains the data at the specified location in the database at the time of the event in its VALUE property.
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let userDictionary = snapshot.value as? [String: Any] else {return}
            let user = User(uid: uid, dictionary: userDictionary)
            
            completion(user)
            
        }) { (err) in
            print("Failed to fetch user for posts ")
        }
    }
}
