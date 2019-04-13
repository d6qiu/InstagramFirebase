//
//  LoginController.swift
//  InstagramFirebase
//
//  Created by wenlong qiu on 10/21/18.
//  Copyright © 2018 wenlong qiu. All rights reserved.
//

import UIKit
import Firebase
class LoginController: UIViewController {
    
    let logoContainerView : UIView = {
       let view = UIView()
        
        let logoImageView = UIImageView(image: UIImage(named: "Instagram_logo_white"))
        logoImageView.contentMode = .scaleAspectFill //fil the bounds of view, keeping aspect ratio, theres also .scaleAspectFit, play with it, command click to see other options
        
        view.addSubview(logoImageView)
        logoImageView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 50)
        //alignment, dont want to stretch, want to keep height and width contraint
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        
        view.backgroundColor = UIColor.rgb(red: 0, green: 120, blue: 175)
        return view
    }()
    
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.backgroundColor = UIColor(white: 0, alpha: 0.03) //0 white means black alpha 0.03 of black gets u white grey
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 14)
        
        textField.addTarget(self, action: #selector(handlerTextInputChange), for: .editingChanged)
        
        return textField
    }()
    
    
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.backgroundColor = UIColor(white: 0, alpha: 0.03) //0 means black alpha 0.03 of black gets u white grey
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.addTarget(self, action: #selector(handlerTextInputChange), for: .editingChanged)
        return textField
    }()
    
    
    @objc func handlerTextInputChange() {
        let isFormValid = emailTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0
        if isFormValid {
            loginButton.isEnabled = true
            loginButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        } else {
            loginButton.isEnabled = false
            loginButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        }
    }
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log in", for: .normal) //select or highlihgt or normal
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        button.layer.cornerRadius = 5 //changing to round border of button differ from changing UITextfield, layer is for animation
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
    
        button.setTitleColor(.white, for: .normal)
       
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)

        button.isEnabled = false
        return button
    }()
    
   
    
    
    
    
    
    @objc func handleLogin() {
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, err) in
            
            if let err = err {
                print("Failed to sign in with email: ", err)
                return
            }
            
            print("Succesfully logged back in with user: ", result?.user.uid ?? "") //use ?? to get rid warning of fail to unwrap
            
            guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else {return}
            mainTabBarController.setUpViewControllers() //refresh view controller when log in
            
            self.dismiss(animated: true, completion: nil) //so need to present login controller's navigation controlelr again after logged out 
            
        }
    }

    
    let dontHaveAccountButton : UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account?  ", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.rgb(red: 17, green: 154, blue: 237)]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(nil, action: #selector(handleShowSignUp), for: .touchUpInside) //self is bascially nil at the point, if nil, The target object—that is, the object whose action method is called. If you specify nil, UIKit searches the responder chain for an object that responds to the specified action message and delivers the message to that object. self wont be nil when touchupinside triggered
        //print(button.allTargets) target is nil
        return button
    }()
    
    @objc func handleShowSignUp() {
        let signUpController = SignUpController()
        navigationController?.pushViewController(signUpController, animated: true) //login controller's navigation controller presented by maintabcontroller
    }
    
    //changes the status bar on top from black text to white
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        view.addSubview(logoContainerView)
        logoContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 150)
        
        navigationController?.isNavigationBarHidden = true
        
        view.backgroundColor = .white
        
        view.addSubview(dontHaveAccountButton)
        //since self is a controller, you need view.leftAnchor
        dontHaveAccountButton.anchor(top: nil, left: view.leftAnchor , bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        
        setupInputFields()
        
    }
    
    fileprivate func setupInputFields() {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton])
        
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        stackView.anchor(top: logoContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 40, paddingBottom: 0, paddingRight: -40, width: 0, height: 140) //height 40 + 40 + 40 + 10 + 10 for the spacing 40 is set by .fillequally
    }
}
