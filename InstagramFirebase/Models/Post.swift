//
//  Post.swift
//  InstagramFirebase
//
//  Created by wenlong qiu on 10/29/18.
//  Copyright © 2018 wenlong qiu. All rights reserved.
//

import Foundation
//strust is value type class is reference type
struct Post {
    
    let user: User
    let imageUrl: String
    let caption: String
    
    //but u can
    init(user: User, dictionary: [String: Any]) {
        self.user = user
        self.imageUrl = dictionary["imageUrl"] as? String ?? "" //unwrap this way
        self.caption = dictionary["caption"] as? String ?? ""
        
        
    }
}
