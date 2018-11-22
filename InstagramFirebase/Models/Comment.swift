//
//  Comment.swift
//  InstagramFirebase
//
//  Created by wenlong qiu on 11/18/18.
//  Copyright © 2018 wenlong qiu. All rights reserved.
//

import Foundation

struct Comment {
    
    let user: User
    let text: String
    let uid: String
    
    init(user: User, dictionary: [String: Any]) {
        self.user = user
        text = dictionary["text"] as? String ?? "" //dont want text to be nil so ""
        uid = dictionary["uid"] as? String ?? ""
    }
}
