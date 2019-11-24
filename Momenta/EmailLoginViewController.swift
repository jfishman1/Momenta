//
//  LoginViewController.swift
//  humble
//
//  Created by Jonathon Fishman on 9/23/17.
//  Copyright © 2017 GoYoJo. All rights reserved.
//

import UIKit

class EmailLoginViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var loginRegisterSegmentControl: UISegmentedControl!
    @IBOutlet weak var inputsContainerView: UIView!
    @IBOutlet weak var loginRegisterButton: UIButton!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    weak var activeField: UITextField?
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
        loginRegisterSegmentControl.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        loginRegisterSegmentControl.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .valueChanged)
        inputsContainerView.layer.cornerRadius = 5
        inputsContainerView.layer.masksToBounds = true
        loginRegisterButton.isEnabled = false
        loginRegisterButton.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        loginRegisterButton.layer.cornerRadius = 5
        
        NotificationCenter.default.addObserver(self, selector: #selector(EmailLoginViewController.keyboardDidShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EmailLoginViewController.keyboardWillBeHidden(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBOutlet weak var inputsContainerViewHeightAnchor: NSLayoutConstraint!
    
    @objc func handleLoginRegisterChange() {
        let title = loginRegisterSegmentControl.titleForSegment(at: loginRegisterSegmentControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: .normal)
        inputsContainerViewHeightAnchor.constant = loginRegisterSegmentControl.selectedSegmentIndex == 0 ? 230 : 115
        firstNameTextField.isHidden = loginRegisterSegmentControl.selectedSegmentIndex == 0 ? false : true
        lastNameTextField.isHidden = loginRegisterSegmentControl.selectedSegmentIndex == 0 ? false : true
    }
    
    func setupTextFields() {
        firstNameTextField.setLeftPaddingPoints(7)
        firstNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        lastNameTextField.setLeftPaddingPoints(7)
        lastNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        emailTextField.setLeftPaddingPoints(7)
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        passwordTextField.setLeftPaddingPoints(7)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
    }
    
    
    @objc func handleLoginRegister() {
        Utility.sharedInstance.showActivityIndicator(view: self.view)
        if loginRegisterSegmentControl.selectedSegmentIndex == 0 {
            registerUser()
        } else {
            loginUser()
        }
    }
    
    func loginUser() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
                print("Form is not valid")
                return
        }
        if !Utility.isValidEmail(emailAddress: emailTextField.text!) {
            Utility.sharedInstance.hideActivityIndicator(view: self.view)
            Utility.showAlert(viewController: self, title: "Login Error", message: "Please enter a valid email address.", completion: {})
            return
        }
        Cloud.sharedInstance.loginWithEmail(email: email, password: password, completion: { (currentUserId) in
            //print("currentUserId = \(currentUserId)")
            Cloud.sharedInstance.fetchUserData(userId: currentUserId, completion: { (user) in
                Utility.sharedInstance.writeUserDataToArchiver(user: user, completion: {
                    Utility.sharedInstance.hideActivityIndicator(view: self.view)
                    self.performSegue(withIdentifier: "toMain", sender: self)
                    self.navigationController?.viewControllers.removeAll()
                })
            }, err: {
                Utility.sharedInstance.hideActivityIndicator(view: self.view)
                Utility.showAlert(viewController: self, title: "Network Error", message: "Sorry, we did not detect an internet connection, please try again.", completion: {})
            })
        }, err: { error in
            print("error = \(error)")
            Utility.sharedInstance.hideActivityIndicator(view: self.view)
            self.passwordTextField.text = ""
            Utility.showAlert(viewController: self, title: "Login Error", message: "Please check your email and password. Then try again.", completion: {})
        })
    }
    
    func registerUser() {
        guard let email = emailTextField.text, let password = passwordTextField.text, let firstName = firstNameTextField.text, let lastName = lastNameTextField.text else {
            Utility.sharedInstance.hideActivityIndicator(view: self.view)
            return
        }
        if !Utility.isValidEmail(emailAddress: emailTextField.text!) {
            Utility.sharedInstance.hideActivityIndicator(view: self.view)
            Utility.showAlert(viewController: self, title: "Email Error", message: "Please enter a valid email address.", completion: {})
            return
        }
        Cloud.sharedInstance.createUserWithEmail(email: email, password: password, firstName: firstName, lastName: lastName, completion: {(uid, values) in
            let user = User(userDictionary: values as [String: AnyObject])
            self.user = user
            Cloud.sharedInstance.fetchUserData(userId: uid, completion: { (user) in
                Utility.sharedInstance.writeUserDataToArchiver(user: user, completion: {
                    Utility.sharedInstance.hideActivityIndicator(view: self.view)
                    self.performSegue(withIdentifier: "toProfile", sender: self)
                })
            }, err: {
                Cloud.sharedInstance.updateUserInDatabaseWithUID(uid: uid, values: values, completion: { 
                    Utility.sharedInstance.writeUserDataToArchiver(user: user, completion: {
                        Utility.sharedInstance.hideActivityIndicator(view: self.view)
                        self.performSegue(withIdentifier: "toProfile", sender: self)
                    })
                })
            })
        }, err: { error in
            print("error = \(error)")
            Utility.sharedInstance.hideActivityIndicator(view: self.view)
            self.passwordTextField.text = ""
            Utility.showAlert(viewController: self, title: "Registration Error", message: "\(error.localizedDescription)", completion: {})
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toProfile" {
            let destinationNavigationController = segue.destination as! UINavigationController
            let targetController = destinationNavigationController.topViewController as! ProfileViewController
            targetController.user = self.user
            targetController.firstTimeRegisteringUser = true
        }
    }
    
    @IBAction func onDismissButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // turn status bar content white
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        
        // Check if the activeField is non-nil and whether or not we can get access to the keyboard's size info.
        if let activeField = self.activeField, let keyboardSize = ((notification as NSNotification).userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height + 120, right: 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            var shortenedViewFrame = self.view.frame
            shortenedViewFrame.size.height -= keyboardSize.size.height
            if !shortenedViewFrame.contains(activeField.frame.origin) {
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    @objc func keyboardWillBeHidden(_ notification: Notification) {
        
        // Move the UIScrollView back to its normal position.
        let contentInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
    }
    
}

extension EmailLoginViewController: UITextFieldDelegate {
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        switch loginRegisterSegmentControl.selectedSegmentIndex {
        case 1:
            forgotPasswordButton.isHidden = false
            if emailTextField.text == "" || passwordTextField.text == "" {
                loginRegisterButton.isEnabled = false
                loginRegisterButton.backgroundColor = .lightGray
                loginRegisterButton.setTitleColor(UIColor.darkGray, for: .normal)
            } else if emailTextField.text != "" && passwordTextField.text != "" {
                loginRegisterButton.isEnabled = true
                loginRegisterButton.backgroundColor = .white
                loginRegisterButton.setTitleColor(Utility.sharedInstance.mainGreen, for: .normal)
            }
        default:
            forgotPasswordButton.isHidden = true
            if firstNameTextField.text == "" || lastNameTextField.text == "" || emailTextField.text == "" || passwordTextField.text == "" {
                loginRegisterButton.isEnabled = false
                loginRegisterButton.backgroundColor = .lightGray
                loginRegisterButton.setTitleColor(UIColor.darkGray, for: .normal)
            } else if firstNameTextField.text != "" && lastNameTextField.text != "" && emailTextField.text != "" && passwordTextField.text != "" {
                loginRegisterButton.isEnabled = true
                loginRegisterButton.backgroundColor = .white
                loginRegisterButton.setTitleColor(Utility.sharedInstance.mainGreen, for: .normal)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard!
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeField = nil
    }
}
