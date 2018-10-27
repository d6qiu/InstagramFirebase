//
//  UserProfileHeader.swift
//  InstagramFirebase
//
//  Created by wenlong qiu on 10/13/18.
//  Copyright © 2018 wenlong qiu. All rights reserved.
//

import UIKit

class UserProfileHeader: UICollectionViewCell{
    
    var user: User? {
        didSet {
            setUpProfileImage()
            
            usernameLabel.text = user?.username
        }
    }
    
    let profileImageView: UIImageView = {
       let iv = UIImageView()
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 14)
        return label
    }()
    
    //MARK: - Bottom tool bar variables
    let gridButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "grid"), for: .normal)
        return button
    }()
    
    let listButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "list"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "ribbon"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    
    //MARK: - User stats view variables
    let postLabel: UILabel = {
       let label = UILabel()
        //NSAtttributedString is the string, .key are the attributes
        let attributedText = NSMutableAttributedString(string: "11\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
        
        attributedText.append(NSAttributedString(string: "posts", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font
            : UIFont.systemFont(ofSize: 14)]))
        
        label.attributedText = attributedText
        
        label.numberOfLines = 0 //use as many line as needed to display label's text
        label.textAlignment = .center
        return label
    }()
    
    let followersLabel: UILabel = {
        let label = UILabel()
        
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
        
        attributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font
            : UIFont.systemFont(ofSize: 14)]))
        
        label.attributedText = attributedText
        
        label.numberOfLines = 0 //use as many line as needed to display label's text
        label.textAlignment = .center
        return label
    }()
    
    let followingLabel: UILabel = {
        let label = UILabel()
        
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
        
        attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font
            : UIFont.systemFont(ofSize: 14)]))
        
        label.attributedText = attributedText
        
        label.numberOfLines = 0 //use as many line as needed to display label's text
        label.textAlignment = .center
        return label
    }()
    
    let editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1 //default is 0 which means no border
        button.layer.cornerRadius = 3
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //add to subview before anchor, else there's nothing to anchor
        addSubview(profileImageView)
        //topAnchor equivalent to self.topAnchor, top left corner
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        profileImageView.layer.cornerRadius = 80 / 2
        profileImageView.clipsToBounds = true //does same thing as layer.maskSToBounds, image is the subview of UIimageView?
        //profileImageView.layer.masksToBounds = true
        setupBottomToolbar()
        
        addSubview(usernameLabel)
        //has to set up bottomtoolbar anchor first cuz gridButton.topAnchor aint initialized yet, if width or height = 0, it streches
        usernameLabel.anchor(top: profileImageView.bottomAnchor, left: self.leftAnchor, bottom: gridButton.topAnchor, right: self.rightAnchor, paddingTop: 4, paddingLeft: 12, paddingBottom: 0, paddingRight: -12, width: 0, height: 0)
        
        setupUserStatsView()
        
        addSubview(editProfileButton)
        editProfileButton.anchor(top: postLabel.bottomAnchor, left: postLabel.leftAnchor, bottom: nil, right: followingLabel.rightAnchor, paddingTop: 2, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 34)
        
        
    }
    
    fileprivate func setupUserStatsView() {
        let stackView = UIStackView(arrangedSubviews: [postLabel, followersLabel, followingLabel])
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        
        //view wont show up until you anchored it, dont forget translatesAutoresizingMaskIntoConstraints = false, but called inside anchor
        stackView.anchor(top: self.topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: -12, width: 0, height: 50)
    }
    
    fileprivate func setupBottomToolbar() {
        
        let topDividerView = UIView()
        topDividerView.backgroundColor = UIColor.lightGray
        
        let botDividerView = UIView()
        botDividerView.backgroundColor = UIColor.lightGray
        
        let stackView = UIStackView(arrangedSubviews: [gridButton, listButton, bookmarkButton])
        
        stackView.axis = .horizontal //default is horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.anchor(top: nil, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50) //set width to 0 to allow it to stretch 
        
        addSubview(topDividerView)
        topDividerView.anchor(top: stackView.topAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        addSubview(botDividerView)
        botDividerView.anchor(top: stackView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    
    
    fileprivate func setUpProfileImage() {
        guard let profileImageUrl = user?.profileImageUrl else {return}
        
        guard let url = URL(string: profileImageUrl) else {return}
        //API for downloading content
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            //if let for check nil, guard let for check not nil and unwrap
            if let err = err {
                print("failed to fetch profile image: ", err)
                return
            }
            
            //check for response status of 200(HTTP OK)???
            //let response  = response as! HTTPURLResponse
            //response.statusCode
            
            guard let data = data else {return}
            
            let image = UIImage(data: data)
            //move from background to main queue
            DispatchQueue.main.async {
                self.profileImageView.image = image
            }
        }.resume() //resumes the task if suspended, Newly-initialized tasks begin in a suspended state, so you need to call this method to start the task.
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

