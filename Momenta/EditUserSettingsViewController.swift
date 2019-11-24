//
//  EditUserSettingsViewController.swift
//  humble
//
//  Created by Jonathon Fishman on 3/8/18.
//  Copyright © 2018 GoYoJo. All rights reserved.
//

import UIKit

class EditUserSettingsViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    
    var user: User? {
        didSet {
            if let firstName = user?.firstName {
                firstNameTextField.text = firstName
            } else {
                firstNameTextField.placeholder = "First Name"
            }
            if let lastName = user?.lastName {
                lastNameTextField.text = lastName
            } else {
                lastNameTextField.placeholder = "Last Name"
            }
            
            emailTextField.text = user!.email ?? ""
        }
    }
    override func viewWillAppear(_ animated: Bool) {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstNameTextField.addTarget(self, action: #selector(textFieldChanged(textField:)), for: UIControlEvents.editingChanged)
        lastNameTextField.addTarget(self, action: #selector(textFieldChanged(textField:)), for: UIControlEvents.editingChanged)
        emailTextField.addTarget(self, action: #selector(textFieldChanged(textField:)), for: UIControlEvents.editingChanged)
    }
    @objc func textFieldChanged(textField: UITextField) {
        
        if firstNameTextField.text == "" || lastNameTextField.text == "" || emailTextField.text == "" {
            
            saveBarButton.isEnabled = false
            
        } else if firstNameTextField.text != "" && lastNameTextField.text != "" && emailTextField.text != "" {
            
            saveBarButton.isEnabled = true
        }
    }

    @IBAction func onSaveBarButton(_ sender: UIBarButtonItem) {
        saveBarButton.isEnabled = false
        Utility.sharedInstance.showActivityIndicator(view: self.view)
        guard let uid = user?.userId else {
            Utility.showAlert(viewController: self, title: "Save Error", message: "Please try again", completion: {})
            return
        }
        let values: [String: AnyObject] = ["firstName": firstNameTextField.text! as AnyObject, "lastName": lastNameTextField.text! as AnyObject, "email": emailTextField.text! as AnyObject]
        Cloud.sharedInstance.updateUserInDatabaseWithUID(uid: uid, values: values, completion: {
            Utility.sharedInstance.hideActivityIndicator(view: self.view)
            self.dismiss(animated: true, completion: nil)
        })
    }
    @IBAction func onCancelBarButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
        
    }
}
