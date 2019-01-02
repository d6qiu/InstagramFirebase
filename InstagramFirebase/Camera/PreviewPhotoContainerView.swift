//
//  PreviewPhotoContainerView.swift
//  InstagramFirebase
//
//  Created by wenlong qiu on 11/16/18.
//  Copyright © 2018 wenlong qiu. All rights reserved.
//

import UIKit
import Photos
class PreviewPhotoContainerView: UIView {
    
    let previewImageView: UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "cancel_shadow")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(nil, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    
    
    let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "save_shadow")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(nil, action: #selector(handleSave), for: .touchUpInside)
        return button
    }()
    
    
    @objc func handleSave() {
        //closure is a nameless function that can be referenced by a strong pointer like below, but now thing is a strong pointer that points to self but will disappear when function is over, self dont have a pointer to thing, if thing is a instance var then will create memeory cycle
        //let thing = {self.saveButton.showsTouchWhenHighlighted = false}
        
        guard let previewImage = previewImageView.image else {return}
        let library = PHPhotoLibrary.shared()
        library.performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: previewImage)
            
        }) { (success, err) in
            if let err = err {
                print("failed to save image to photo library ", err)
                return
            }
            
            print("successfully saved image to library")
            DispatchQueue.main.async { [weak self] in//whenever some ui elements lagging, try use main thread
                let savedLabel = UILabel()
                savedLabel.text = "Saved Successfully"
                savedLabel.font = UIFont.boldSystemFont(ofSize: 18)
                savedLabel.textColor = .white
                savedLabel.numberOfLines = 0
                savedLabel.textAlignment = .center
                savedLabel.backgroundColor = UIColor(white: 0, alpha: 0.3)
                //using frame to animate ui elements in and out of the view
                savedLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 80)
                savedLabel.center = (self?.center)!
                self?.addSubview(savedLabel)
                
                savedLabel.layer.transform = CATransform3DMakeScale(0, 0, 0) //whenever animation, think layer, instant transfromation
                
                //transfrom over time
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                    savedLabel.layer.transform = CATransform3DMakeScale(1, 1, 1) //transform from size 0 to original size
                }, completion: { (completed) in
                    UIView.animate(withDuration: 0.5, delay: 0.75, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                        savedLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                        savedLabel.alpha = 0
                        
                    }, completion: { (_) in //if not going to use something, replace with _
                        savedLabel.removeFromSuperview()
                    })
                })
            }
            
        }
    }
    
    @objc func handleCancel() {
        self.removeFromSuperview() //cuz addsubview(thisview) in superview
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .yellow
        
        addSubview(previewImageView)
        previewImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        addSubview(cancelButton)
        cancelButton.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        
        addSubview(saveButton)
        saveButton.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 24, paddingBottom: -24, paddingRight: 0, width: 50, height: 50)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
