//
//  CommentInputAccessoryView.swift
//  InstagramFirebase
//
//  Created by wenlong qiu on 11/23/18.
//  Copyright © 2018 wenlong qiu. All rights reserved.
//

import UIKit

protocol CommentInputAccessoryViewDelegate {
    func didSubmit(for comment: String)
}


class CommentInputAccessoryView: UIView  {
    
    var delegate: CommentInputAccessoryViewDelegate?
    
    func clearCommentTextField() {
        //commentTextView.text = nil
        commentTextView.showPlaceholderLabel()
    }
    
    //setting var private so when debugg you know for sure it is not outside class causing the error
    fileprivate let commentTextView: CommentInputTextView = { //commentinputtextview is a custom textfield with placeholder 
        let tv = CommentInputTextView()
        tv.isScrollEnabled = false //make textfield taller
        tv.font = UIFont.systemFont(ofSize: 18)
        
        return tv
    }()
    
    private let submitButton: UIButton = {
        let sb = UIButton(type: .system) //.system makes button pressed down when tap it
        sb.setTitle("Submit", for: .normal)
        sb.setTitleColor(.black, for: .normal)
        sb.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        sb.addTarget(nil, action: #selector(handleSubmit), for: .touchUpInside)
        
        return sb
    }()
    
    override init(frame: CGRect) { //avoid bloating initilizers 
        super.init(frame: frame)
        //1, fix commment textfield so low
        autoresizingMask = .flexibleHeight //caller resizes its height  base on superview/ commentsController's view bounds
        
        backgroundColor = .white
        
        addSubview(submitButton)
        submitButton.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: -12, width: 50, height: 50)
        
        addSubview(commentTextView)
        //3 saftarea
        commentTextView.anchor(top: topAnchor, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: submitButton.leftAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 0, width: 0, height: 0)
        
        setupLineSeperatorView()
        
    }
    //2
    //no boundries, resize base on content
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    fileprivate func setupLineSeperatorView() { //because UIview
        let lineSeperatorView = UIView()
        lineSeperatorView.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        addSubview(lineSeperatorView)
        lineSeperatorView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    @objc func handleSubmit() {
        
        guard let commentText = commentTextView.text else {return}
        delegate?.didSubmit(for: commentText)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
