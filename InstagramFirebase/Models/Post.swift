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
    let imageUrl: String //struct dont need initializers, class does
    
    //but u can
    init(dictionary: [String: Any]) {
        imageUrl = dictionary["imageUrl"] as? String ?? "" //unwrap this way 
    }
}
