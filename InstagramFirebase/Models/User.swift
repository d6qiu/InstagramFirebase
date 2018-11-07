//
//  User.swift
//  InstagramFirebase
//
//  Created by wenlong qiu on 11/4/18.
//  Copyright © 2018 wenlong qiu. All rights reserved.
//

import Foundation
//groups information, cleans code, //instead of fetching user profile image again from database, create a user struct, stores fetched database data inside, and send it header by header.user = self.user at line 125
struct User {
    let uid: String
    let username: String
    let profileImageUrl: String
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        username = dictionary["username"] as? String ?? ""
        profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
    }
}
