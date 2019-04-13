//
//  UserProfileHeader.swift
//  InstagramFirebase
//
//  Created by wenlong qiu on 10/13/18.
//  Copyright © 2018 wenlong qiu. All rights reserved.
//

import UIKit
import Firebase

protocol UserProfileHeaderDelegate {
    func didChangeToListView()
    func didChangeToGridView()
}


class UserProfileHeader: UICollectionViewCell{
    
    var delegate: UserProfileHeaderDelegate?
    
    var user: User? {
        didSet {
            guard let profileImageUrl = user?.profileImageUrl else {return}
            profileImageView.loadImage(urlString: profileImageUrl)
            
            usernameLabel.text = user?.username
            
            setupEditFollowButton()
            
        }
    }
    
    fileprivate func setupEditFollowButton() {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else {return}
        guard let userId = user?.uid else {return}
        if currentLoggedInUserId == userId {

        } else {
            Database.database().reference().child("following").child(currentLoggedInUserId).child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let isFollowing = snapshot.value as? Int, isFollowing == 1 {
                    self.editProfileFollowButton.setTitle("Unfollow", for: .normal)
                } else {
                    self.setupFollowStyle()
                }
                
            }) { (err) in
            
                print("failed to check if  following:", err)
            }
            
        }

    }
    
    @objc func handleEditProfileOrFollow() {
        
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else {return}
        guard let userId = user?.uid else {return}
        
        if editProfileFollowButton.titleLabel?.text == "Unfollow" {
            //removeValue will remove the current child
            Database.database().reference().child("following").child(currentLoggedInUserId).child(userId).removeValue { (err, ref) in //remove value removes caller ie child(userid)
                if let err = err {
                    print("failed to unfollow person", err)
                    return
                }
                
                self.setupFollowStyle()
                print("successfully unfollowed person", self.user?.username ?? "")
            }
            
            
        } else if editProfileFollowButton.titleLabel?.text == "Follow" {
            let ref = Database.database().reference().child("following").child(currentLoggedInUserId)
            let values = [userId: 1]
            //update current child's values
            ref.updateChildValues(values) { (err, ref) in
                if let err = err {
                    print("faile to follow user: ", err)
                    return
                }
                
                self.editProfileFollowButton.setTitle("Unfollow", for: .normal)
                self.editProfileFollowButton.backgroundColor = .white
                self.editProfileFollowButton.setTitleColor(.black, for: .normal)
                print("succesfullly follow user: ", self.user?.username ?? "")
            }
            
        }
        
    }
    fileprivate func setupFollowStyle() {
        self.editProfileFollowButton.setTitle("Follow", for: .normal)
        self.editProfileFollowButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        self.editProfileFollowButton.setTitleColor(.white, for: .normal)
        self.editProfileFollowButton.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor

    }
    
    let profileImageView: CustomImageView = {
       let iv = CustomImageView()
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 14)
        return label
    }()
    
    //MARK: - Bottom tool bar variables
    lazy var gridButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "grid"), for: .normal)
        button.addTarget(self, action: #selector(handleChangeToGridView), for: .touchUpInside)
        return button
    }()
    
    @objc func handleChangeToGridView() {
        gridButton.tintColor = UIColor.mainBlue()
        listButton.tintColor = UIColor(white: 0, alpha: 0.2)
        delegate?.didChangeToGridView()
    }
    
    lazy var listButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "list"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        button.addTarget(self, action: #selector(handleChangeToListView), for: .touchUpInside)
        return button
    }()
    
    @objc func handleChangeToListView() {
        listButton.tintColor = UIColor.mainBlue()
        gridButton.tintColor = UIColor(white: 0, alpha: 0.2)
        delegate?.didChangeToListView() //tells useprofilecontroller to change the ui elements, this class dont have the scope to do so
    }
    
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
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
        
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
    
    lazy var editProfileFollowButton: UIButton = { //if let editProfile doesnt work, use lazy var 
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1 //default is 0 which means no border
        button.layer.cornerRadius = 3
        
        button.addTarget(self, action: #selector(handleEditProfileOrFollow), for: .touchUpInside)
        //print(button.allTargets.first?.description)
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
        usernameLabel.anchor(top: profileImageView.bottomAnchor, left: self.leftAnchor, bottom: gridButton.topAnchor, right: self.rightAnchor, paddingTop: 4, paddingLeft: 12, paddingBottom: 0, paddingRight: -12, width: 0, height: 0) //default text alignment is left
        
        setupUserStatsView()
        
        addSubview(editProfileFollowButton)
        editProfileFollowButton.anchor(top: postLabel.bottomAnchor, left: postLabel.leftAnchor, bottom: nil, right: followingLabel.rightAnchor, paddingTop: 2, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 34)
        
        
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
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

