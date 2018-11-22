//
//  CommentCell.swift
//  InstagramFirebase
//
//  Created by wenlong qiu on 11/17/18.
//  Copyright © 2018 wenlong qiu. All rights reserved.
//

import UIKit

class CommentCell: UICollectionViewCell {
    
    var comment: Comment? {
        didSet {
            guard let comment = comment else {return}
            
            let attributedText = NSMutableAttributedString(string: comment.user.username, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSMutableAttributedString(string: " " + comment.text, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)]))
            textView.attributedText = attributedText
            profileImageView.loadImage(urlString: comment.user.profileImageUrl)
            
        }
    }
    
    let textView: UITextView = { //textview starts line on top, uilabel starts text at center
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        //label.numberOfLines = 0 //have as much as lines u need to render the text
        textView.isScrollEnabled = false //disable scroll view so dummyCell.systemLayoutSizeFitting(targetSize) in sizeforitem in commentscontroller wont accout for scroll view's constraint
        return textView
    }()
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        profileImageView.layer.cornerRadius = 40 / 2 
        
        addSubview(textView)
        textView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: -4, paddingRight: -4, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
