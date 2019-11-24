//
//  AddCommentViewController.swift
//  humble
//
//  Created by Jonathon Fishman on 4/11/18.
//  Copyright © 2018 GoYoJo. All rights reserved.
//

import UIKit
import MobileCoreServices
import Firebase

class AddCommentViewController: UIViewController  {

    @IBOutlet weak var commentDescriptionTextView: UITextView!
    @IBOutlet weak var characterCountLabel: UILabel!
    @IBOutlet weak var removeImageViewButton: UIButton!
    @IBOutlet weak var commentImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var libraryButton: UIButton!
    @IBOutlet weak var postBarButtonItem: UIBarButtonItem!
    
    var user: User?
    var post: Post? 
    var defaultCommentDescription = "Add a short comment..."
    var commentDescription: String?
    var selectedImageFromPicker: UIImage?
    var imageUrl: String?
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getDataUpdate), name: NSNotification.Name(rawValue: userDataManagerDidUpdateCurrentUserNotification), object: nil)
        UserDataManager.sharedInstance.requestCurrentUserData()
    }
    @objc private func getDataUpdate() {
        if let userData = UserDataManager.sharedInstance.currentUserData {
            self.user = userData
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: userDataManagerDidUpdateCurrentUserNotification), object: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentDescriptionTextView.delegate = self
        commentDescriptionTextView.text = commentDescription ?? defaultCommentDescription
        removeImageViewButton.layer.cornerRadius = 15
        removeImageViewButton.clipsToBounds = true
    }

    @IBAction func onDismissBarButton(_ sender: UIBarButtonItem) {
        if commentDescription != nil || commentImageView.image != nil {
            let alertController = UIAlertController(title: "Discard Comment",
                                                    message: "Are you sure you want to discard this comment?",
                                                    preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
                return
            }
            alertController.addAction(cancelAction)
            let discardAction = UIAlertAction(title: "Discard", style: .destructive) { action in
                self.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(discardAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func onCameraButton(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            //performSegue(withIdentifier: "goToCamera", sender: self)
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.mediaTypes = [kUTTypeImage as String]
            //imagePicker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
            imagePicker.allowsEditing = true
            //imagePicker.videoMaximumDuration = 10.0//180.0
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    @IBAction func onLibraryButton(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            //imagePicker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.navigationBar.tintColor = .darkGray
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func onRemoveImageButton(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Discard Image",
                                    message: "Are you sure you want to discard the image?",
                                    preferredStyle: .alert)
            
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            return
        }
        alertController.addAction(cancelAction)
        let discardAction = UIAlertAction(title: "Discard", style: .destructive) { action in
            self.commentImageView.image = nil
            self.commentImageView.isHidden = true
            self.removeImageViewButton.isHidden = true
            self.cameraButton.isHidden = false
            self.libraryButton.isHidden = false
        }
        alertController.addAction(discardAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onPostBarButton(_ sender: UIBarButtonItem) {
        if commentDescriptionTextView.text == defaultCommentDescription {
            Utility.showAlert(viewController: self, title: "No Description", message: "Please add a short description", completion: {})
            return
        } else {
            commentDescription = commentDescriptionTextView.text
        }
        if commentImageView.image == nil {
            let alertController = UIAlertController(title: "No Image Added",
                                                    message: "Sure you don't want to add an image?",
                                                    preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "I'm sure", style: .default) { action in
                self.finishCommentSetup()
            }
            alertController.addAction(okAction)
            let cancelAction = UIAlertAction(title: "I'll add one!", style: .cancel) { action in
                return
            }
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            self.imageUrl = "\(UUID().uuidString).jpg"
            finishCommentSetup()
        }
    }
    private func finishCommentSetup() {
        guard let postId = self.post!.postId else {
            return
        }
        guard let commentCreatorId = self.user!.userId else {
            Utility.showAlert(viewController: self, title: "Please login", message: "You are currently not logged in to post anything", completion: {})
            Utility.sharedInstance.logoutAndRemoveUserDefaults()
            return
        }
        guard let commentorName = self.user!.firstName else {
            Utility.showAlert(viewController: self, title: "Please login", message: "You are currently not logged in to post anything", completion: {})
            Utility.sharedInstance.logoutAndRemoveUserDefaults()
            return
        }
        let commentorImageUrl = self.user!.smallProfileImageUrl ?? ""
        let comment = self.commentDescription!
        let commentImageUrl = self.imageUrl ?? ""
        let timestamp = Int(Date().timeIntervalSince1970)
        
        let properties = ["postId": postId, "commentCreatorId": commentCreatorId, "commentorName": commentorName, "commentorImageUrl": commentorImageUrl, "comment": comment, "commentImageUrl": commentImageUrl, "timestamp": timestamp] as [String : AnyObject]
        
        createCommentWithProperties(properties: properties)
    }
    
    private func createCommentWithProperties(properties: [String: AnyObject]) {
        postBarButtonItem.isEnabled = false
        Utility.sharedInstance.showActivityIndicator(view: self.view)
        let ref = Database.database().reference().child("comments")
        let childRef = ref.childByAutoId()
        let commentId = childRef.key
        let postId = properties["postId"] as! String
        let commentCreatorId = properties["commentCreatorId"] as! String
        let commentImageUrl = properties["commentImageUrl"] as? String ?? ""
        var values: [String: AnyObject] = ["commentId": commentId as AnyObject]
        properties.forEach( {values[$0] = $1} )
        // save comment to comments
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            // save commentId to commentCreator
            let commentCreatorRef = Database.database().reference().child("users").child(commentCreatorId).child("comments")
            commentCreatorRef.updateChildValues([commentId:1])
            
            // save postId to groups
            let userGroupRef = Database.database().reference().child("users").child(commentCreatorId).child("groups")
            userGroupRef.updateChildValues([postId:1])
            
            // save post-comments
            let postCommentsRef = Database.database().reference().child("post-comments").child(postId)
            postCommentsRef.updateChildValues([commentId:1])
            
            // update post supporters and momentum
//            var postSupportersCount = self.post?.supporterIds?.count ?? 0
//            postSupportersCount += 1
            var postMomentumCount = self.post?.momentumCount ?? 0
            postMomentumCount += 1
            let postValuesToUpdate: [String: AnyObject] = ["momentumCount": postMomentumCount as AnyObject]
            let postRef = Database.database().reference().child("posts").child(postId)
            postRef.updateChildValues(postValuesToUpdate)
            
            let postSupportersRef = postRef.child("supporterIds")
            postSupportersRef.updateChildValues([commentCreatorId:1])
            
            // update postCreatorSupporters
            if let postCreatorId = self.post?.creatorId {
                let postCreatorSupportersRef = Database.database().reference().child("users").child(postCreatorId).child("supporters")
                postCreatorSupportersRef.updateChildValues([commentCreatorId:1])
                // add image to firebase storage
                if commentImageUrl != "" {
                    Cloud.sharedInstance.uploadCommentImageWithNameToFirebaseStorage(self.commentImageView.image!, filePath: .comment_images, imageName: commentImageUrl, commentId: commentId ?? "new_comment", completion: {
                        Utility.sharedInstance.hideActivityIndicator(view: self.view)
                        self.performSegue(withIdentifier: "unwindToPostDetailVC", sender: self)
                    })
                } else {
                    Utility.sharedInstance.hideActivityIndicator(view: self.view)
                    self.performSegue(withIdentifier: "unwindToPostDetailVC", sender: self)
                }
            }
        }
    }
}

extension AddCommentViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        if mediaType == kUTTypeImage as String {
            //let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            handleImageSelectedForInfo(info: info as [String : AnyObject])
        }
//        else if mediaType == kUTTypeMovie as String {
//            if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL {
//                handleVideoSelectedForUrl(url: videoUrl)
//            }
//        }
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func handleImageSelectedForInfo(info: [String: AnyObject]) {
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        self.cameraButton.isHidden = true
        self.libraryButton.isHidden = true
        self.removeImageViewButton.isHidden = false
        self.commentImageView.isHidden = false
        self.commentImageView.image = selectedImageFromPicker
    }
}

extension AddCommentViewController: UITextViewDelegate {
    // TextView Delegate methods
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == commentDescriptionTextView {
            if(text == "\n") {
                view.endEditing(true)
                return false
            }
            let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
            self.characterCountLabel.text = "\(300 - newText.count)"
            return newText.count < 300
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        postBarButtonItem.isEnabled = false
        if textView == commentDescriptionTextView {
            if textView.text == defaultCommentDescription {
                textView.text = nil
                textView.textColor = UIColor.darkGray
                characterCountLabel.isHidden = false
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        postBarButtonItem.isEnabled = true
        if textView == commentDescriptionTextView {
            if textView.text.isEmpty {
                textView.text = defaultCommentDescription
                textView.textColor = UIColor.lightGray
                commentDescription = nil
            } else {
                self.commentDescription = textView.text
            }
        }
    }
}
