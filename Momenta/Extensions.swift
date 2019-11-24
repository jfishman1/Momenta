//
//  Extensions.swift
//  humble
//
//  Created by Jonathon Fishman on 10/1/17.
//  Copyright © 2017 GoYoJo. All rights reserved.
//

import UIKit

extension PostDetailViewController: PostDetailViewModelDelegate {
    func apply(changes: SectionChanges) {
        self.tableView?.beginUpdates()
        
        self.tableView?.deleteSections(changes.deletes, with: .fade)
        self.tableView?.insertSections(changes.inserts, with: .fade)
        
        self.tableView?.reloadRows(at: changes.updates.reloads, with: .fade)
        self.tableView?.insertRows(at: changes.updates.inserts, with: .fade)
        self.tableView?.deleteRows(at: changes.updates.deletes, with: .fade)
        
        self.tableView?.endUpdates()
    }
}

extension ProfileViewController: ProfileViewModelDelegate {
    func apply(changes: SectionChanges) {
        self.tableView?.beginUpdates()
        
        self.tableView?.deleteSections(changes.deletes, with: .fade)
        self.tableView?.insertSections(changes.inserts, with: .fade)
        
        self.tableView?.reloadRows(at: changes.updates.reloads, with: .fade)
        self.tableView?.insertRows(at: changes.updates.inserts, with: .fade)
        self.tableView?.deleteRows(at: changes.updates.deletes, with: .fade)
        
        self.tableView?.endUpdates()
    }
}

extension Array where Element: Hashable {
    
    /// Remove duplicates from the array, preserving the items order
    func filterDuplicates() -> Array<Element> {
        var set = Set<Element>()
        var filteredArray = Array<Element>()
        for item in self {
            if set.insert(item).inserted {
                filteredArray.append(item)
            }
        }
        return filteredArray
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}


extension UIColor {
        
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}

extension UIView {
    
    func addConstraintsWithFormat(format: String, views: UIView...) {
        
        var viewsDictionary = [String : UIView]()
        for (i, view) in views.enumerated() {
            let key = "v\(i)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
    }
}

//// memory bank for all images being downloaded
//let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    // cacheing
    func loadImageUsingCacheWithUrlString(urlString: String) {
        
        self.image = nil // stops images from flashing and setting wrong image on the tableview
        
        // check cache for image first
        if let cachedImage = Utility.sharedInstance.imageCache.object(forKey: urlString as NSString) as? UIImage {
            self.image = cachedImage
            return
        }
        
        // otherwise fire a new download
        let url = URL(string: urlString)
        // execute this to download the image off of main queue
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            //download hit an error so lets return out
            if let error = error {
                print(error)
                return
            }
            //download is successful
            
            // we need to run image setter (all UI updates) on main queue
            DispatchQueue.main.async(execute: {
                
                if let downloadedImage = UIImage(data: data!) {
                    Utility.sharedInstance.imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                    
                    self.image = downloadedImage
                }
            })
        }).resume() // needed to fire off URL session request
    }
}


extension UIImage {
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFill
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}




extension UIButton {
    func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 900, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22)], context: nil)
    }
    
    func setLeftAlignPadding(_ amount: CGFloat){
        contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        imageEdgeInsets = UIEdgeInsets(top: 0, left: amount, bottom: 0, right: 0)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: amount + 5, bottom: 0, right: 0)
    }
}

extension UINavigationItem {
    func setupLeftBarProfileButton(button: UIButton, user: User?) -> UIBarButtonItem {
        button.imageView!.contentMode = .scaleAspectFill
        button.layer.cornerRadius = 15
        button.clipsToBounds = true
        
        if let userData = user {//Utility.sharedInstance.loadUserDataFromArchiver() {
            if let smallProfileImageUrl = userData.smallProfileImageUrl {
                if smallProfileImageUrl == "" || smallProfileImageUrl == "SmallProfileDefault" {
                    button.setImage(UIImage(named:"SmallProfileDefault"), for: .normal)
                } else if Utility.sharedInstance.imageCache.object(forKey: smallProfileImageUrl as NSString) != nil {
                    button.setImage(Utility.sharedInstance.imageCache.object(forKey: smallProfileImageUrl as NSString) as? UIImage, for: .normal)
                } else {
                    Utility.sharedInstance.loadImageFromUrl(photoUrl: smallProfileImageUrl, completion: { imageData in
                        if let smallProfileImage = UIImage(data: imageData) {
                            button.setImage(smallProfileImage, for: .normal)
                            Utility.sharedInstance.imageCache.setObject(smallProfileImage, forKey: smallProfileImageUrl as NSString)
                        }
                    }, loadError: { print("error loading image from URL")
                        button.setImage(UIImage(named: "SmallProfileDefault"), for: .normal)
                    })
                }
            }
        } else {
            button.setImage(UIImage(named:"SmallProfileDefault"), for: .normal)
        }
        let leftBarButton = UIBarButtonItem(customView: button)
        let width = leftBarButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        width?.isActive = true
        let height = leftBarButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        height?.isActive = true
        return leftBarButton
    }
}
