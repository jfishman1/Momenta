//
//  CreatePostViewController.swift
//  humble
//
//  Created by Jonathon Fishman on 3/20/18.
//  Copyright © 2018 GoYoJo. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import FirebaseDatabase
import FirebaseFunctions


class CreatePostViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var postDescriptionTextView: UITextView!
    @IBOutlet weak var characterCountLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var removeImageViewButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var libraryButton: UIButton!
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var doneEditPostTextButton: UIButton!
    @IBOutlet weak var postBarButtonItem: UIBarButtonItem!
    
    weak var activeView: UITextView?
    
    var user: User?
    var category: String? {
        didSet {
            categoryButton.setTitle(category!, for: .normal)
        }
    }
    let defaultPostDescription = "Add a short description..."
    var postDescription: String?
    var selectedImageFromPicker: UIImage?
    var defaultPostText = "Tell your story..."
    var postText: String?
    var imageUrl: String?
    //let videoUrl: String?
    
    // Firebase Functions
    lazy var functions = Functions.functions()
    
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
        postDescriptionTextView.delegate = self
        postTextView.delegate = self
        postDescriptionTextView.text = postDescription ?? defaultPostDescription
        postTextView.text = postText ?? defaultPostText
        removeImageViewButton.layer.cornerRadius = 15.0
        removeImageViewButton.clipsToBounds = true
        doneEditPostTextButton.layer.cornerRadius = 15.0
        doneEditPostTextButton.clipsToBounds = true
    
        NotificationCenter.default.addObserver(self, selector: #selector(CreatePostViewController.keyboardDidShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(CreatePostViewController.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        //NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @IBAction func onDismissBarButton(_ sender: UIBarButtonItem) {
        if postDescription != nil || postText != nil || postImageView.image != nil {
            let alertController = UIAlertController(title: "Discard Post",
                                                    message: "Are you sure you want to discard this post?",
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
    
    @IBAction func onSelectCategoryButton(_ sender: UIButton) {
        performSegue(withIdentifier: "toSelectCategory", sender: sender)
    }
    @IBAction func unwindToCreatePostVC(segue: UIStoryboardSegue) {
        if segue.source.isKind(of: SelectCategoryViewController.self) {
            let prevVC = segue.source as! SelectCategoryViewController
            self.category = prevVC.selectedCategory!
        }
    }
    
    @IBAction func onPostBarButton(_ sender: UIBarButtonItem) {
        if categoryButton.title(for: .normal) == "Select Category" {
            Utility.showAlert(viewController: self, title: "No Category", message: "Please select a category", completion: {})
            return
        }
        if postDescription == nil || postDescription == defaultPostDescription {
            if postDescriptionTextView.text == defaultPostDescription || postDescriptionTextView.text == "" {
                Utility.showAlert(viewController: self, title: "No Description", message: "Please add a short description", completion: {})
                return
                } else {
                postDescription = postDescriptionTextView.text
            }
        }
        if postImageView.image == nil && postTextView.text == defaultPostText || postTextView.text == "" {
            let alertController = UIAlertController(title: "No Extra Content",
                                                    message: "Sure you don't want to add an image or extra text?",
                                                    preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "I'm sure!", style: .default) { action in
                self.finishPostSetup()
            }
            alertController.addAction(okAction)
            let cancelAction = UIAlertAction(title: "I'll add more", style: .cancel) { action in
                return
            }
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            if postImageView.image != nil {
                imageUrl = "\(UUID().uuidString)"
            } else if postTextView.text != nil && postTextView.text != "" {
                if postText == nil {
                    postText = postTextView.text
                }
            }
            finishPostSetup()
        }
    }
    func finishPostSetup() {
        guard let creatorId = self.user!.userId else {
            Utility.showAlert(viewController: self, title: "Please login", message: "You are currently not logged in to post anything", completion: {})
            Utility.sharedInstance.logoutAndRemoveUserDefaults()
            return
        }
        guard let creatorName = self.user!.firstName else {
            Utility.showAlert(viewController: self, title: "Please login", message: "You are currently not logged in to post anything", completion: {})
            Utility.sharedInstance.logoutAndRemoveUserDefaults()
            return
        }
        let creatorImageUrl = self.user?.smallProfileImageUrl ?? ""
        let timestamp = Int(Date().timeIntervalSince1970)
        guard let category = self.category else {
            return
        }
        guard let postDescription = self.postDescription else {
            return
        }
        let postImageUrl = imageUrl ?? ""
        let postVideoUrl = ""
        if postText == nil {
            postText = ""
        }
        let properties = ["creatorId": creatorId, "creatorName": creatorName, "creatorImageUrl": creatorImageUrl, "timestamp": timestamp, "category": category, "postDescription": postDescription, "postImageUrl": postImageUrl, "postVideoUrl": postVideoUrl, "postText": postText!] as [String : AnyObject]
        createPostWithProperties(properties: properties, postImageUrl: postImageUrl)
    }
    
    func createPostWithProperties(properties: [String: AnyObject], postImageUrl: String) {
        postBarButtonItem.isEnabled = false
        Utility.sharedInstance.showActivityIndicator(view: self.view)
        let ref = Database.database().reference().child("posts")
        let childRef = ref.childByAutoId()
        let postId = childRef.key
        let creatorId = properties["creatorId"] as! String
        var values: [String: AnyObject] = ["postId": postId as AnyObject]
        properties.forEach({values[$0] = $1})
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            let userPostCreatorRef = Database.database().reference().child("users").child(creatorId).child("posts")
            userPostCreatorRef.updateChildValues([postId:1])
            
            let userGroupRef = Database.database().reference().child("users").child(creatorId).child("groups")
            userGroupRef.updateChildValues([postId:1])
            
            print("properties: " + properties.debugDescription)
            
            Utility.sharedInstance.writeUpdatedUserPostDataToArchiver(user: self.user!, post: [postId!:1], completion: {
                let postImageUrl = properties["postImageUrl"] as! String
                if postImageUrl != "" {
                    Cloud.sharedInstance.uploadPostImageWithNameToFirebaseStorage(self.postImageView.image!, imageName: postImageUrl, postId: postId!, completion: {
                        self.dismiss(animated: true, completion: {
                            Utility.sharedInstance.hideActivityIndicator(view: self.view)
                            // osDemo get firebase function reference
                            self.sendOneSignalNotificationThroughFirebaseFunctions(properties: properties)
                        })
                    })
                } else {
                    self.dismiss(animated: true, completion: {
                        Utility.sharedInstance.hideActivityIndicator(view: self.view)
                        // osDemo get firebase function reference
                        self.sendOneSignalNotificationThroughFirebaseFunctions(properties: properties)
                    })
                }
            })
        }
    }
    // osDemo get firebase function reference
    func sendOneSignalNotificationThroughFirebaseFunctions(properties: [String: AnyObject]) {
        print("properties 2: " + properties.debugDescription)
        // [START function_add_numbers]
        let data = ["contents": properties["postDescription"],
                    "category": properties["category"]]
        print("data.contents: ", data["contents"] as! String)
        print("data.category: ", data["category"] as! String)
        self.functions.httpsCallable("sendNotificationFromOS").call(data) { (result, error) in
          // [START function_error]
          if let error = error as NSError? {
            if error.domain == FunctionsErrorDomain {
//              let code = FunctionsErrorCode(rawValue: error.code)
//              let message = error.localizedDescription
//              let details = error.userInfo[FunctionsErrorDetailsKey]
            }
            // [START_EXCLUDE]
            print(error.localizedDescription)
            return
            // [END_EXCLUDE]
          }
          // [END function_error]
          if let operationResult = (result?.data as? [String: Any])?["operationResult"] as? Int {
            print("operationResult: \(operationResult)")
          }
        }
        // [END function_add_numbers]
    }
    
    @IBAction func onCameraButton(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            //performSegue(withIdentifier: "goToCamera", sender: self)
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
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
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            //imagePicker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
            imagePicker.mediaTypes = [kUTTypeImage as String]
            //imagePicker.navigationBar.tintColor = .darkGray
            imagePicker.allowsEditing = true
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func onTextButton(_ sender: UIButton) {
        hideInputButtons(true)
        showPostTextView(true)
    }
    @IBAction func onDoneEditTextButton(_ sender: UIButton) {
        postTextView.resignFirstResponder()
    }
    
    @IBAction func onRemoveImageButton(_ sender: UIButton) {
        if postTextView.text == "" || postTextView.text == defaultPostText  {
            self.postImageView.image = nil
            self.showImageView(false)
            self.postTextView.text = self.defaultPostText
            self.postTextView.textColor = .lightGray
            self.postText = nil
            self.postTextView.resignFirstResponder()
            self.showPostTextView(false)
            self.hideInputButtons(false)
        } else {
            let alertController = UIAlertController(title: "Discard Additions",
                                                    message: "Are you sure you want to discard these additions?",
                                                    preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
                return
            }
            
            alertController.addAction(cancelAction)
            
            let discardAction = UIAlertAction(title: "Discard", style: .destructive) { action in
                self.postImageView.image = nil
                self.showImageView(false)
                self.postTextView.text = self.defaultPostText
                self.postTextView.textColor = .lightGray
                self.postText = nil
                self.postTextView.resignFirstResponder()
                self.showPostTextView(false)
                self.hideInputButtons(false)
            }
            alertController.addAction(discardAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

extension CreatePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        let mediaType = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaType)] as! String
        if mediaType == kUTTypeImage as String {
            //let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            handleImageSelectedForInfo(info: info as [String : AnyObject])
        } else if mediaType == kUTTypeMovie as String {
            if let videoUrl = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaURL)] as? URL {
                handleVideoSelectedForUrl(url: videoUrl)
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func handleVideoSelectedForUrl(url: URL) {
        Cloud.sharedInstance.uploadMovieToFirebaseStorage(url: url, filePath: .post_movies, completion: { (properties) in
            self.hideInputButtons(true)
            self.showImageView(true)
            self.postImageView.image = properties["imageUrl"] as? UIImage
        }, err: { error in
            Utility.showAlert(viewController: self, title: "Error Uploading Video", message: error.localizedDescription, completion: {})
        })
    }
    
    fileprivate func handleImageSelectedForInfo(info: [String: AnyObject]) {
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        hideInputButtons(true)
        showImageView(true)
        self.postImageView.image = selectedImageFromPicker
    }
    
    func hideInputButtons(_ answer: Bool) {
        self.cameraButton.isHidden = answer
        self.libraryButton.isHidden = answer
        self.textButton.isHidden = answer
    }
    
    func showImageView(_ answer: Bool) {
        self.removeImageViewButton.isHidden = !answer
        self.postImageView.isHidden = !answer
    }
    
    func showPostTextView(_ answer: Bool) {
        self.postTextView.isHidden = !answer
        self.removeImageViewButton.isHidden = !answer
        self.doneEditPostTextButton.isHidden = !answer
    }
}


extension CreatePostViewController: UITextViewDelegate {
    
    // TextView Delegate methods
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == postDescriptionTextView {
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
        if textView == postDescriptionTextView {
            if textView.text == defaultPostDescription {
                textView.text = nil
                textView.textColor = UIColor.white
                characterCountLabel.isHidden = false
            }
        } else {
            doneEditPostTextButton.isHidden = false
            self.activeView = postTextView
            if textView.text == defaultPostText {
                textView.text = nil
                textView.textColor = UIColor.darkGray
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        postBarButtonItem.isEnabled = true
        if textView == postDescriptionTextView {
            if textView.text.isEmpty {
                textView.text = defaultPostDescription
                textView.textColor = UIColor.lightGray
                postDescription = nil
            } else {
                self.postDescription = textView.text
            }
        } else if textView == postTextView {
            doneEditPostTextButton.isHidden = true
            if textView.text.isEmpty {
                textView.text = defaultPostText
                textView.textColor = UIColor.lightGray
                postText = nil
            } else {
                self.postText = textView.text
            }
        }
    }
    @objc func keyboardDidShow(_ notification: Notification) {
        if let activeView = self.activeView, let keyboardSize = ((notification as NSNotification).userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            
            var shortenedViewFrame = self.view.frame
            shortenedViewFrame.size.height -= keyboardSize.size.height
            
            if !shortenedViewFrame.contains(activeView.frame.origin) {
                self.scrollView.scrollRectToVisible(activeView.frame, animated: true)
            }
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
