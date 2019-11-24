//
//  GroupChatLogController.swift
//  humble
//
//  Created by Jonathon Fishman on 10/19/17.
//  Copyright © 2017 GoYoJo. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class GroupChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    var group: Post? {
        didSet {
            navigationItem.title = group?.postDescription
            observeGroupChats()
        }
    }
    
    var groupChats = [GroupChat]()
    var currentUser: User?
    
    func observeGroupChats() {
        guard let groupId = group?.postId else {
            return
        }
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        //-------------------------------------------
        var blockedUsers = [String]()
        let blockedUsersRef = Database.database().reference().child("users").child(uid).child("blockedUsers")
        blockedUsersRef.observe(.childAdded, with: { (snapshot) in
            //print(snapshot)
            let blockedUserId = snapshot.key
            //print("blockedUserId: ", blockedUserId)
            blockedUsers.append(blockedUserId)
        })
        let userMessagesRef = Database.database().reference().child("group-chats").child(groupId)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            //print(snapshot)// prints messages for user
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child("group-chats").child(messageId)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                //print(snapshot)
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                let groupChat = GroupChat(groupChatDictionary: dictionary)
                if !blockedUsers.contains(groupChat.fromId!) {
                    self.groupChats.append(groupChat)
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData() // changes UI so needs to be put on main thread
                        //scroll to the last index when image or text is added
                        let indexPath = IndexPath(item: self.groupChats.count - 1, section: 0)
                        self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                    }
                }
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    let cellId = "cellId"

    override func viewDidLoad() {
        super.viewDidLoad()
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        longPressRecognizer.minimumPressDuration = 0.2
        longPressRecognizer.delegate = self
        longPressRecognizer.delaysTouchesBegan = true
        self.collectionView?.addGestureRecognizer(longPressRecognizer)

        collectionView?.contentInset = UIEdgeInsets.init(top: 8, left: 0, bottom: 8, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = .white
        collectionView?.register(GroupChatMessageViewCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .interactive
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        setupKeyboardObservers()
    }
    @objc func longPressed(gestureRecognizer: UILongPressGestureRecognizer) {
        if (gestureRecognizer.state != .ended){
            return
        }
        let p = gestureRecognizer.location(in: self.collectionView)
        
        if let indexPath : IndexPath = self.collectionView?.indexPathForItem(at: p) {
            let groupChatMessage = groupChats[indexPath.item]
            let selectedUserId = groupChatMessage.fromId
            if selectedUserId != currentUser?.userId {
                showOptionsAlertSheet(selectedUserId: selectedUserId!)
            }
        }
    }
    
    func showOptionsAlertSheet(selectedUserId: String) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let reportAction = UIAlertAction(title: "Block User?", style: .destructive, handler: {
            (alert: UIAlertAction) -> Void in
            Utility.sharedInstance.blockUserAlert(viewController: self, currentUserId: self.currentUser!.userId!, blockedUserId: selectedUserId)
        })
        alertController.addAction(reportAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    lazy var inputContainerView: ChatInputContainerView = {
        let chatInputContainerView = ChatInputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        chatInputContainerView.groupChatLogController = self
        return chatInputContainerView
    }()
    
    @objc func handleUploadTap() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.navigationBar.tintColor = .darkGray
        // adding video to image picture
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        if let videoUrl = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaURL)] as? URL {
            //we selected a video
            handleVideoSelectedForUrl(videoUrl)
        } else {
            //we selected an image
            handleImageSelectedForInfo(info: info as [String : AnyObject])
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func handleVideoSelectedForUrl(_ url: URL) {
        let filename = UUID().uuidString + ".mov"
        let storageRef = Storage.storage().reference().child("message_movies").child(filename)
        storageRef.putFile(from: url, metadata: nil, completion: { (metadata, error) in
            if error != nil, metadata != nil {
                print("Failed upload of video:", error!)
                return
            }
            storageRef.downloadURL(completion: { (videoUrl, error) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                let videoUrl = videoUrl?.absoluteString
                if let thumbnailImage = self.thumbnailImageForFileUrl(url) {
                    self.uploadToFirebaseStorageUsingImage(thumbnailImage, completion: { (imageUrl) in
                        let properties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth": thumbnailImage.size.width as AnyObject, "imageHeight": thumbnailImage.size.height as AnyObject, "videoUrl": videoUrl as AnyObject]
                        self.sendMessageWithProperties(properties)
                    })
                }
            })
            // shows status of video upload in nav bar
//            uploadTask.observe(.progress) { (snapshot) in
//                if let completedUnitCount = snapshot.progress?.completedUnitCount {
//                    self.navigationItem.title = String(completedUnitCount)
//                }
//            }
//            uploadTask.observe(.success) { (snapshot) in
//                self.navigationItem.title = self.group?.postDescription
//            }
        })
    }
    
    fileprivate func thumbnailImageForFileUrl(_ fileUrl: URL) -> UIImage? {
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
            
        } catch let err {
            print(err)
        }
        
        return nil
    }
    
    fileprivate func handleImageSelectedForInfo(info: [String: AnyObject]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            uploadToFirebaseStorageUsingImage(selectedImage, completion: { (imageUrl) in
                self.sendMessageWithImageUrl(imageUrl: imageUrl, image: selectedImage)
            })
        }
    }
    
    fileprivate func uploadToFirebaseStorageUsingImage(_ image: UIImage, completion: @escaping (_ imageUrl: String) -> ()) {
        let imageName = UUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imageName)
        
        if let uploadData = image.jpegData(compressionQuality: 0.2) {
            ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    print("Failed to upload image:", error!)
                    return
                }
                ref.downloadURL(completion: { (imageUrl, error) in
                    if error != nil {
                        return
                    }
                    if let imageUrl = imageUrl?.absoluteString {
                        completion(imageUrl)
                    }
                })                
            })
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // want to allow the textfield to follow the keyboard when goes up and down with animation
    // when overriding a property on UIViewController, you need specify a get
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        //        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        //
        //        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func handleKeyboardDidShow() {
        if groupChats.count > 0 {
            let indexPath = IndexPath(item: groupChats.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }
    
    // prevent memory leaks with NotificatinCenter
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
//    func handleKeyboardWillShow(notification: Notification) {
//        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as
//            AnyObject).cgRectValue
//        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
//        //print(keyboardFrame!.height)
//        containerViewBottomAnchor?.constant = -keyboardFrame!.height
//        UIView.animate(withDuration: keyboardDuration!, animations: { self.view.layoutIfNeeded() })
//    }
//
//    func handleKeyboardWillHide(notification: Notification) {
//        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
//        containerViewBottomAnchor?.constant = 0
//        UIView.animate(withDuration: keyboardDuration!, animations: { self.view.layoutIfNeeded() })
//    }

    
    // MARK: UICollectionViewDataSource

//    override func numberOfSections(in collectionView: UICollectionView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groupChats.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! GroupChatMessageViewCell
        
        cell.groupChatLogController = self
        
        let groupChatMessage = groupChats[indexPath.item]
        cell.groupChat = groupChatMessage
        cell.textView.text = groupChatMessage.text
        
        setupCell(cell: cell, groupChatMessage: groupChatMessage)
        
        if let text = groupChatMessage.text {
            // modify the bubbleView width, created bubbleWidthAnchor in ChatMessageCell
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32
            cell.textView.isHidden = false
        } else if groupChatMessage.imageUrl != nil {
            //fall in here if its an image message
            cell.bubbleWidthAnchor?.constant = 200
            // textView is blocking images from being clicked
            cell.textView.isHidden = true
        }
        
        cell.playButton.isHidden = groupChatMessage.videoUrl == nil
        
        return cell
    }
    
    private func setupCell(cell: GroupChatMessageViewCell, groupChatMessage: GroupChat) {
        if let profileImageUrl = groupChatMessage.profileImageUrl {
            if profileImageUrl != "" {
                cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
            } else {
                cell.profileImageView.image = UIImage(named: "SmallProfileDefault")
            }
        } else {
            cell.profileImageView.image = UIImage(named: "SmallProfileDefault")
        }
        
        if groupChatMessage.fromId == Auth.auth().currentUser?.uid {
            // outgoing message
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = UIColor.white
            // hide senders profile imge
            cell.profileImageView.isHidden = true
            
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
        } else {
            // incoming message
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = UIColor.black
            // don't hide profile image
            cell.profileImageView.isHidden = false
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
        
        if let messageImageUrl = groupChatMessage.imageUrl {
            cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
        } else {
            cell.messageImageView.isHidden = true
        }
    }
    
    // for landscape mode
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        
        //get estimated height
        let message = groupChats[indexPath.item]
        if let text = message.text {
            height = estimateFrameForText(text: text).height + 20
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            
            // h1 / w1 = h2 / w2
            // solve for h1
            // h1 = h2 / w2 * w1
            
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    // for estimating height
    private func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    @objc func handleSend() {
        let properties = ["text": inputContainerView.inputTextField.text!]
        sendMessageWithProperties(properties as [String : AnyObject])
    }
    
    fileprivate func sendMessageWithImageUrl(imageUrl: String, image: UIImage) {
        let properties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth": image.size.width as AnyObject, "imageHeight": image.size.height as AnyObject]
        sendMessageWithProperties(properties)
    }
    
    fileprivate func sendMessageWithProperties(_ properties: [String: AnyObject]) {
        let ref = Database.database().reference().child("group-chats")
        let childRef = ref.childByAutoId()
        let fromId = Auth.auth().currentUser!.uid
        let timestamp = Int(Date().timeIntervalSince1970)
        
        let profileImageUrl = currentUser!.smallProfileImageUrl ?? ""
        
        var values: [String: AnyObject] = ["fromId": fromId as AnyObject, "timestamp": timestamp as AnyObject, "profileImageUrl": profileImageUrl as AnyObject]
        
        //append properties dictionary onto values somehow??
        //key $0, value $1
        properties.forEach({values[$0] = $1})
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            
            self.inputContainerView.inputTextField.text = nil
            
            let groupMessagesRef = Database.database().reference().child("group-chats").child(self.group!.postId!)
            
            let messageId = childRef.key
            groupMessagesRef.updateChildValues([messageId: 1])
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    // custom zooming logic
    func performZoomInForStartingImageView(_ startingImageView: UIImageView) {
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)
            
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackBackgroundView?.alpha = 1
                self.inputContainerView.alpha = 0
                
                // math?
                // h2 / w1 = h1 / w1
                // h2 = h1 / w1 * w1
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                
                zoomingImageView.center = keyWindow.center
                
            }, completion: { (completed) in
                // do nothing
            })
        }
    }
    
    @objc func handleZoomOut(_ tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            //need to animate back out to controller
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
                
            }, completion: { (completed) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
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
