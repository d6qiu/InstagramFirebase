//
//  PhotoSelectorCell.swift
//  InstagramFirebase
//
//  Created by wenlong qiu on 10/26/18.
//  Copyright © 2018 wenlong qiu. All rights reserved.
//

import UIKit

class PhotoSelectorCell: UICollectionViewCell {
    
    let photoImageView: UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleAspectFill //scale aspect fill will exceed bounds
        iv.clipsToBounds = true //clips the exceeded bounds
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(photoImageView)
        photoImageView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
