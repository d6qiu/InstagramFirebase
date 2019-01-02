//
//  CustomImageView.swift
//  InstagramFirebase
//
//  Created by wenlong qiu on 10/31/18.
//  Copyright © 2018 wenlong qiu. All rights reserved.
//

import UIKit

var imageCache = [String: UIImage]()

class CustomImageView: UIImageView {
    
    var lastURLUsedToLoad: String?
    func loadImage(urlString: String) {
        
        weak var weakSelf = self
        lastURLUsedToLoad = urlString
        
        self.image = nil //gets rid of flicking
        
        //downloading image cost network data usage, so cache them 
        if let cachedImage = imageCache[urlString] {
            self.image = cachedImage
            return
        }
        
        guard let url = URL(string: urlString) else {return}
        //API for downloading content
        URLSession.shared.dataTask(with: url) { [weak self](data, response, err) in //fetching data would be done in background
            //if let for check nil, guard let for check not nil and unwrap
            if let err = err {
                print("Failed to fetch image with url", err)
                return
            }
            
            //check for response status of 200(HTTP OK)???
            //let response  = response as! HTTPURLResponse
            //response.statusCode
            
            if url.absoluteString != self?.lastURLUsedToLoad { //if not equal means completion method overlap with second reload
                return
            }
            
            
            guard let imageData = data else {return}
            let photoImage = UIImage(data: imageData)
            
            imageCache[url.absoluteString] = photoImage
            
            DispatchQueue.main.async { [weak self] in
                self?.image = photoImage
            }
        }.resume() ////resumes the task if suspended, Newly-initialized tasks begin in a suspended state, so you need to call this method to start the task.
    }
}
