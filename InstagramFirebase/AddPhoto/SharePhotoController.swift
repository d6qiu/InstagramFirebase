//
//  SharePhotoController.swift
//  InstagramFirebase
//
//  Created by wenlong qiu on 10/27/18.
//  Copyright © 2018 wenlong qiu. All rights reserved.
//

import UIKit
import Firebase
class SharePhotoController: UIViewController {
    var selectedImage: UIImage? {
        didSet {
            imageView.image = selectedImage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240) //greyish background
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(handleShare))
        
        setupImageAndTextViews()
    }
    
    let imageView: UIImageView = {
       let iv = UIImageView()
        iv.backgroundColor = .red
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true //clip exceeding pixels
        return iv
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
       tv.font = UIFont.systemFont(ofSize: 14)
        return tv
    }()
    
    fileprivate func setupImageAndTextViews() {
        let containerView = UIView()
        containerView.backgroundColor = .white
        
        view.addSubview(containerView) //need view.addSubview is self is controller
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 100) //view.safearealayoutguide is area unobscured by bars etc
        
        containerView.addSubview(imageView)
        imageView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: -8, paddingRight: 0, width: 84, height: 0) //height will constraint to 84, so set width to 84
        
        containerView.addSubview(textView)
        textView.anchor(top: containerView.topAnchor, left: imageView.rightAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    @objc func handleShare() {
        
        guard let caption = textView.text, caption.count > 0 else {
            print("empty share text")
            return
        } //if empty text will return fail to load data
        guard let image = selectedImage else {return}
        guard let uploadData = image.jpegData(compressionQuality: 0.5) else {return}
        
        navigationItem.rightBarButtonItem?.isEnabled = false //disable share button
        
        let filename = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("post").child(filename)
        
        storageRef.putData(uploadData, metadata: nil) { (metadata, err) in
            if let err = err {
                print("failed to upload share image", err)
                return
            }
            storageRef.downloadURL(completion: { (downloadURL, err) in
                if let err = err {
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    print("failed to get downloadurl when sharing", err)
                    return
                }
                guard let imageUrl = downloadURL?.absoluteString else {return}
                print("succesfully upload share image ")
                
                self.saveToDatabaseWithImageUrl(imageUrl: imageUrl)
                
            })
        }
    }
    
    fileprivate func saveToDatabaseWithImageUrl(imageUrl: String) {
        guard let postImage = selectedImage else {return}
        guard let caption = textView.text else {return}
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let userPostRef = Database.database().reference().child("posts").child(uid)
        let ref = userPostRef.childByAutoId() //new child location
        
        let values = ["imageUrl": imageUrl, "caption": caption, "imageWidth": postImage.size.width, "imageHeight": postImage.size.height, "creationDate": Date().timeIntervalSince1970] as [String : Any] //need the cast if heterogenous dictionary
        ref.updateChildValues(values) { (err, ref) in
            if let err = err {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("failed to save post to DB", err)
                return
            }
            print("succesfully saved post to DB")
            
            self.dismiss(animated: true, completion: nil) //dismiss will dismiss whatever was presented, i.e the photoselectorcontroller' navigation controller presented in maintabbarcontroller 
            
        }
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
