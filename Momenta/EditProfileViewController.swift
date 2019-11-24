//
//  EditProfileViewController.swift
//  humble
//
//  Created by Jonathon Fishman on 2/24/18.
//  Copyright © 2018 GoYoJo. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    
    var bigImageName: String?
    var smallImageName: String?
    var bigUploadData: Data?
    var smallUploadData: Data?
    var didSelectNewImage = false {
        didSet {
            print("didSelectNewImage: ", didSelectNewImage)
            if didChangeAttributes == false && didSelectNewImage == false {
                saveButton.isEnabled = false
            } else {
                saveButton.isEnabled = true
                //saveButton.setTitleColor(.white, for: .normal)
                let origImage = UIImage(named: "checkmark icon")
                let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
                saveButton.setImage(tintedImage, for: .normal)
                saveButton.tintColor = .white
            }
        }
    }
    var didChangeAttributes = false {
        didSet {
            print("didChangeAttributes: ", didChangeAttributes)
            if didChangeAttributes == false && didSelectNewImage == false {
                saveButton.isEnabled = false
            } else {
                saveButton.isEnabled = true
                //saveButton.setTitleColor(.white, for: .normal)
                let origImage = UIImage(named: "checkmark icon")
                let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
                saveButton.setImage(tintedImage, for: .normal)
                saveButton.tintColor = .white
            }
        }
    }
    var name = "Name"
    var user: User? {
        didSet {
            if didSelectNewImage != true {
                if let profileImageUrl = user?.bigProfileImageUrl {
                    if profileImageUrl != "BigProfileDefault" {
                        profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
                    } else {
                        profileImageView.image = UIImage(named: "BigProfileDefault")
                    }
                } else {
                    profileImageView.image = UIImage(named: "BigProfileDefault")
                }
            }
            let firstName = user?.firstName ?? "Name"
            let lastName = user?.lastName ?? ""
            name = "\(firstName) \(lastName) "
            nameButton.setTitle(name, for: .normal)
            let attributes = user?.attributes ?? ["Acceptance"]
            attributesArray = attributes
        }
    }
    var setFirstTime = true
    var attributesArray = [String]() {
        didSet {
            if setFirstTime == true {
                highlightSelectedButtons()
                setFirstTime = false
            }
        }
    }
    var selectedButtonsArray = [EditProfileButton]()
    var allButtonsArray = [EditProfileButton]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barStyle = .blackOpaque
        nameButton.semanticContentAttribute = .forceRightToLeft
        saveButton.isEnabled = false
        saveButton.setTitleColor(.lightGray, for: .normal)
        profileImageView.layer.cornerRadius = 60
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
    }
    override func viewWillAppear(_ animated: Bool) {
        addButtonsToAllButtonsArray()
        NotificationCenter.default.addObserver(self, selector: #selector(getDataUpdate), name: NSNotification.Name(rawValue: userDataManagerDidUpdateCurrentUserNotification), object: nil)
        UserDataManager.sharedInstance.requestCurrentUserData()
    }
    @objc private func getDataUpdate() {
        if let currentUserData = UserDataManager.sharedInstance.currentUserData {
            self.user = currentUserData
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: userDataManagerDidUpdateCurrentUserNotification), object: self)
    }
    
    func addButtonsToAllButtonsArray() {
        for subview in self.contentView.subviews {
            if subview is EditProfileButton {
                allButtonsArray.append(subview as! EditProfileButton)
            }
        }
    }
    func highlightSelectedButtons() {
        for button in allButtonsArray {
            let buttonTitle = button.titleLabel!.text!
            if attributesArray.contains(buttonTitle) {
                button.backgroundColor = Utility.sharedInstance.mainGreen
                button.setTitleColor(.white, for: .normal)
                button.titleLabel!.font = UIFont(name: "HelveticaNeue-Bold", size: 12.0)
                selectedButtonsArray.append(button)
            }
        }
    }

    @IBAction func onSaveButton(_ sender: UIButton) {
        let values = ["attributes":attributesArray] as [String: AnyObject]
        Utility.sharedInstance.showActivityIndicator(view: self.view)
        if didSelectNewImage == true {
            saveUserProfileImages(values: values)
        } else {
            Cloud.sharedInstance.updateUserInDatabaseWithUID(uid: user!.userId!, values: values as [String: AnyObject], completion: {
                Cloud.sharedInstance.fetchUserData(userId: self.user!.userId!, completion: { userData in
                    Utility.sharedInstance.writeUserDataToArchiver(user: userData, completion: {
                        self.waitToDismiss()
                    })
                }, err: {
                    Utility.sharedInstance.hideActivityIndicator(view: self.view)
                    Utility.showAlert(viewController: self, title: "Network Error", message: "Sorry, we did not detect an internet connection, please try again.", completion: {})
                })
            })
        }
    }
    func saveUserProfileImages(values: [String: AnyObject]) {
        Cloud.sharedInstance.saveUserProfileImages(uid: user!.userId!, bigImageName: bigImageName!, smallImageName: smallImageName!, bigUploadData: bigUploadData!, smallUploadData: smallUploadData!, completion: {
            if self.didChangeAttributes == true {
                Cloud.sharedInstance.updateUserInDatabaseWithUID(uid: self.user!.userId!, values: values as [String: AnyObject], completion: {
                    Cloud.sharedInstance.fetchUserData(userId: self.user!.userId!, completion: { userData in
                        Utility.sharedInstance.writeUserDataToArchiver(user: userData, completion: {
                            self.waitToDismiss()
                        })
                    }, err: {
                        Utility.sharedInstance.hideActivityIndicator(view: self.view)
                        Utility.showAlert(viewController: self, title: "Network Error", message: "Sorry, we did not detect an internet connection, please try again.", completion: {})
                    })
                })
            } else {
                Cloud.sharedInstance.fetchUserData(userId: self.user!.userId!, completion: { userData in
                    Utility.sharedInstance.writeUserDataToArchiver(user: userData, completion: {
                        self.waitToDismiss()
                    })
                }, err: {
                    Utility.sharedInstance.hideActivityIndicator(view: self.view)
                    Utility.showAlert(viewController: self, title: "Network Error", message: "Sorry, we did not detect an internet connection, please try again.", completion: {})
                })
            }
        })
    }
    
    @IBAction func onDismissButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onNameButton(_ sender: UIButton) {
        performSegue(withIdentifier: "toEditUserSettings", sender: sender)
    }
    @IBAction func onButtonTap(_ sender: EditProfileButton) {
        didChangeAttributes = true
        if attributesArray.count <= 7 {
            updateButton(sender: sender)
        } else {
            if sender.backgroundColor != .white {
                sender.backgroundColor = .white
                sender.setTitleColor(.darkGray, for: .normal)
                sender.titleLabel!.font = UIFont(name: "HelveticaNeue", size: 12.0)
                attributesArray = attributesArray.filter { $0 != sender.titleLabel!.text! }
                selectedButtonsArray = selectedButtonsArray.filter { $0 != sender }
            } else {
                attributesArray.remove(at: 0)
                let clearedButton = selectedButtonsArray[0]
                clearedButton.backgroundColor = .white
                clearedButton.setTitleColor(.darkGray, for: .normal)
                clearedButton.titleLabel!.font = UIFont(name: "HelveticaNeue", size: 12.0)
                selectedButtonsArray.remove(at: 0)
                updateButton(sender: sender)
            }
        }
    }
    
    func updateButton(sender: EditProfileButton) {
        if sender.backgroundColor == .white {
            sender.backgroundColor = Utility.sharedInstance.mainGreen
            sender.setTitleColor(.white, for: .normal)
            sender.titleLabel!.font = UIFont(name: "HelveticaNeue-Bold", size: 12.0)
            attributesArray.append(sender.titleLabel!.text!)
            selectedButtonsArray.append(sender)
        } else {
            sender.backgroundColor = .white
            sender.setTitleColor(.darkGray, for: .normal)
            sender.titleLabel!.font = UIFont(name: "HelveticaNeue", size: 12.0)
            attributesArray = attributesArray.filter { $0 != sender.titleLabel!.text! }
            selectedButtonsArray = selectedButtonsArray.filter { $0 != sender }
        }
    }
    
    var timer: Timer?
    fileprivate func waitToDismiss() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.handleDismiss), userInfo: nil, repeats: false)
    }
    
    @objc func handleDismiss() {
        Utility.sharedInstance.hideActivityIndicator(view: self.view)
        //self.dismiss(animated: true, completion: nil)
        performSegue(withIdentifier: "unwindFromEditProfile", sender: self)
    }
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.navigationBar.barTintColor = Utility.sharedInstance.mainGreen
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //let selectedPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
        let editedPhoto = info[UIImagePickerControllerEditedImage] as! UIImage
        profileImageView.image = editedPhoto

        let imageUUIDString = UUID().uuidString
        bigImageName = "\(name)_BIG_\(imageUUIDString)"
        smallImageName = "\(name)_SMALL_\(imageUUIDString)"
        if let profileImage = self.profileImageView.image {
            let largeProfileImage = profileImage.resizeImage(image: profileImage, targetSize: CGSize(width: 200.0, height: 200.0))//profileImage.resizeWithWidth(width: 200)
            bigUploadData = UIImageJPEGRepresentation(largeProfileImage, 0.5)
            let smallProfileImage = profileImage.resizeImage(image: profileImage, targetSize: CGSize(width: 60.0, height: 60.0))//profileImage.resizeWithWidth(width: 42)
            smallUploadData = UIImageJPEGRepresentation(smallProfileImage, 0.5)
        }
        didSelectNewImage = true
        dismiss(animated: true, completion: nil)
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

class EditProfileButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderColor = UIColor.darkGray.cgColor
        layer.borderWidth = 1
        backgroundColor = UIColor.white
        setTitleColor(UIColor.darkGray, for: .normal)
        showsTouchWhenHighlighted = true
    }
    
}
