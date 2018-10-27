//
//  ViewController.swift
//  InstagramFirebase
//
//  Created by wenlong qiu on 10/7/18.
//  Copyright © 2018 wenlong qiu. All rights reserved.
//

import UIKit
import Firebase
class SignUpController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{ //delegate allows you to customize response
    
    let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system) //.system makes it when you click it it fades to white for a sec
        //need withrenderingmode else wont work
        button.setImage(UIImage(named: "plus_photo")?.withRenderingMode(.alwaysOriginal) , for: .normal)
        //replacement for IBAction, self.selectorMethod if touched button inside
        button.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
        return button
    }() //excute the block with (), same thing as noNameFunction()
    
    @objc func handlePlusPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self //imagepickercontroll's delegate is type uiimagepcikercontrollerdelegate && uinavigationcontrollerdelegate, set delegate = self means it needs a reference of self object
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    //MARK: - imagePickercontroller delegate methods
    //UIImagePickerController.InfoKey is a struct, .normal, .alwaysOriginal infers type, .editedImage = UIImagePickerController.InfoKey.editedImage, . access from type context
    //. means from another class, otherwise equivalent to self.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            plusPhotoButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info[.originalImage] as? UIImage {
            plusPhotoButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.size.width/2 //sets the radius
        plusPhotoButton.layer.masksToBounds = true //clips the mask to match the bounds
        plusPhotoButton.layer.borderColor = UIColor.black.cgColor //animatin color?
        plusPhotoButton.layer.borderWidth = 3
        
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    @objc func handlerTextInputChange() {
        let isFormValid = emailTextField.text?.count ?? 0 > 0 && usernameTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0
        if isFormValid {
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        } else {
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        }
    }
    
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.backgroundColor = UIColor(white: 0, alpha: 0.03) //0 white means black alpha 0.03 of black gets u white grey
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 14)
        
        textField.addTarget(self, action: #selector(handlerTextInputChange), for: .editingChanged)
        
        return textField
    }()
    
    let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Username"
        textField.backgroundColor = UIColor(white: 0, alpha: 0.03) //0 means black alpha 0.03 of black gets u white grey
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
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal) //select or highlihgt or normal
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        button.layer.cornerRadius = 5 //changing to round border of button differ from changing UITextfield, layer is for animation
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside) //self call this action , UIControl.event areConstants describing the types of events possible for controls.
        button.isEnabled = false
        return button
    }()
    
    @objc func handleSignUp() {
        //textField.text not nil even if empty string, but createUser will fail if empty string
        guard let email = emailTextField.text, email.count > 0 else {return}
        guard let username = usernameTextField.text, username.count > 0 else {return}
        guard let password = passwordTextField.text, password.count > 0 else {return} //return if empty string, let password can take in empty string
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            //check whether error is nil
            if let err = error {
                print("Failed to create user: ", err) //would give you error if any of of the fields are empty
                return
            }
            print("Sucessfully created user: ", result?.user.uid ?? "")
            
            guard let image = self.plusPhotoButton.imageView?.image else {return}
            guard let uploadData = image.jpegData(compressionQuality: 0.3) else {return}//compression quality 0 is the worst
            
            let fileName = NSUUID().uuidString //a complex random string best for keys, UUID are universial unique identifiers
            
            //we assign each user to a random string as key
            let storageRef = Storage.storage().reference().child("profile_images").child(fileName)
            
            storageRef.putData(uploadData, metadata: nil, completion: { (metaData, err) in
                if let err = err {
                    print("failed to uploard profile image: ", err)
                    return
                }
                storageRef.downloadURL(completion: { (downloadURL, err) in
                    if let err = err {
                        print("failed to download URL", err)
                        return
                    }
                    
                    guard let profileImageUrl = downloadURL?.absoluteString else {return}
                    print("succesfully uploaded profile image", profileImageUrl)
                    
                    guard let uid = result?.user.uid else {return}
                    
                    let dictionaryValues = ["username": username, "profileImageUrl": profileImageUrl]
                    let values = [uid: dictionaryValues]
                    
                    //.setValue replace child node //append dictionary //key uid became child 
                    Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (err, ref) in
                            if let err = err {
                                print("failed to save user info into db", err)
                                return
                            }
                            print("successfully saved user info into db")
                        
                        //UIApplication is class, shared returns an instance, keyWindow is the most recenet shown/visible window 
                        guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else {return}
                        mainTabBarController.setUpViewControllers()
                        self.dismiss(animated: true, completion: nil)
                        
                    })
                    
                })
                

            })
        }
      
    }
    
    
    let alreadyHaveAccountButton : UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?  ", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Log In", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.rgb(red: 17, green: 154, blue: 237)]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.addTarget(self, action: #selector(handleAlreadyHaveAccount), for: .touchUpInside) //wants to show logincontroller
        
        return button
    }()
    
    @objc func handleAlreadyHaveAccount() {
        //recall that you pushed self into the controller before in logincontroller.swift, of course poping means deleting this instance, and creats a new one everytime you push
        _ = navigationController?.popViewController(animated: true) //can also use underscore to catch the returned by not gonna use value
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        view.backgroundColor = .white
        view.addSubview(plusPhotoButton)
        
        plusPhotoButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(emailTextField)
        
        setUpInputFields()
        
        
        
    }
    
    fileprivate func setUpInputFields() {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, usernameTextField, passwordTextField, signUpButton])
        stackView.distribution = .fillEqually //infer from distribution's type
        stackView.axis = .vertical
        stackView.spacing = 10
        
        view.addSubview(stackView)
        
        //NSLayoutConstraint.activate([stackView.topAnchor.constraint(equalTo: plusPhotoButton.bottomAnchor, constant: 20), ...])
        
        stackView.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 40, paddingBottom: 0, paddingRight: -40, width: 0, height: 200)
        
    }


}

extension UIView {
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
        
        self.translatesAutoresizingMaskIntoConstraints = false // not using the system's auto resize mask as contraints, using your own contraints // makes object visible
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: paddingBottom).isActive = true
        }
        if let right = right {
            self.rightAnchor.constraint(equalTo: right, constant: paddingRight).isActive = true
        }
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}
