//
//  PhotoSelectorController.swift
//  InstagramFirebase
//
//  Created by wenlong qiu on 10/26/18.
//  Copyright © 2018 wenlong qiu. All rights reserved.
//

import UIKit
import Photos

class PhotoSelectorController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    let headerId = "headerId"
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        setupNavigationButtons()
        
        collectionView.register(PhotoSelectorCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(PhotoSelectorHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        
        fetchPhotos()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedImage = images[indexPath.item]
        collectionView.reloadData()
        
        let indexPath = IndexPath(item: 0, section: 0) //0,0 is the first item in the collection view lay out
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true) //so scroll the first item to the bottom, which means scroll up to see the fullsize image
    }
    
    var selectedImage : UIImage?
    
    var images = [UIImage]()
    
    var assets = [PHAsset]()
    
    fileprivate func assetsFetchOptions() -> PHFetchOptions {
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 30
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false) // sorting each item/asset in the result container by comparing the creationDate variable of each item/asset, like sorting a vector with a comparsion functor
        fetchOptions.sortDescriptors = [sortDescriptor]
        return fetchOptions
    }
    
    fileprivate func fetchPhotos() {
      
        let allPhotos = PHAsset.fetchAssets(with: .image, options: assetsFetchOptions())
        //manipulate threads to reducing freezing/hanging caused by 600 x 600 target size,
        DispatchQueue.global(qos: .background).async { //background thread runs this to allow background color to be loaded first while waiting for selectedImage to be set, so wont freeze up ui
            allPhotos.enumerateObjects { (asset, count, stop) in
                
                //print(asset) //PHAsset contains all sorts of infor about one image, has variable creationDate
                
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 200, height: 200)
                let options = PHImageRequestOptions()
                options.isSynchronous = true //wait til image data is ready before calling resulthandler block, calls handler exactly once, if false,  may call more than once.
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { (image, info) in
                    if let image = image {
                        self.images.append(image)
                        self.assets.append(asset)
                        //image.size.width/height in sitll the same as original. it is logical maintains ratio target size 
                        if self.selectedImage == nil {
                            self.selectedImage = image //set the default selectedImage
                        }
                    }
                    
                    if count == allPhotos.count - 1 {
                        DispatchQueue.main.async { //instantly reloads background on the UI using main thread
                            self.collectionView.reloadData() //reloaddata when data changes, retrieved
            
                        }
                    }
                })
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: width)
    }
    
    var header: PhotoSelectorHeader?
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! PhotoSelectorHeader
        header.photoImageView.image = selectedImage //this line makes no difference 
        
        self.header = header
        
        if let selectedImage  = selectedImage {
            if let index = self.images.firstIndex(of: selectedImage) {
                let selectedAssets = self.assets[index]
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 600, height: 600) //target size only effect the resolution
                imageManager.requestImage(for: selectedAssets, targetSize: targetSize, contentMode: .default, options: nil) { (image, info) in
                    header.photoImageView.image = image
                }
            }
            
        }
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 3) / 4
        return CGSize(width: width, height: width)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PhotoSelectorCell
        
        cell.photoImageView.image = images[indexPath.item] //indexPath is a listof indexes so item is the index
        return cell
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    fileprivate func setupNavigationButtons() {
        navigationController?.navigationBar.tintColor = .black
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext))
    }
    
    @objc func handleNext() {
        let sharePhotoController = SharePhotoController()
        
        sharePhotoController.selectedImage = header?.photoImageView.image
        
        navigationController?.pushViewController(sharePhotoController, animated: true) //push will give us a backbutton
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
}
