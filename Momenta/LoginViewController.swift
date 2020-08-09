//
//  LoginViewController.swift
//  humble
//
//  Created by Jonathon Fishman on 12/4/17.
//  Copyright © 2017 GoYoJo. All rights reserved.
//

import UIKit
import GoogleSignIn
import FacebookLogin
import FBSDKLoginKit
import Firebase

class LoginViewController: UIViewController, GIDSignInDelegate {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    
    //var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Cloud.sharedInstance.setGIDSignInClass()
        //GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        setupButtonAlignment()
        containerView.layer.cornerRadius = 5
        containerView.layer.masksToBounds = true
    }

    func setupButtonAlignment() {
        facebookButton.setLeftAlignPadding(20)
        googleButton.setLeftAlignPadding(20)
        emailButton.setLeftAlignPadding(20)
    }
    
    @IBAction func onFacebookButton(_ sender: UIButton) {
        Utility.sharedInstance.showActivityIndicator(view: self.view)
        Cloud.sharedInstance.loginWithFacebook(viewController: self, completion: {(uid, values) in
            self.fetchOrUpdateUser(uid: uid, values: values)
        }, err: { (error) in
            self.handleError(error: error)
            Utility.sharedInstance.hideActivityIndicator(view: self.view)
        })
    }
    
    @IBAction func onGoogleButton(_ sender: UIButton) {
        Utility.sharedInstance.showActivityIndicator(view: self.view)
        GIDSignIn.sharedInstance().signIn()
    }
    // GIDSignInDelegate Method
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard let thisUser = user else { return }
        guard let authentication = thisUser.authentication else { return }
        Cloud.sharedInstance.loginWithGoogle(authentication: authentication, completion: {(uid, values) in
            self.fetchOrUpdateUser(uid: uid, values: values)
        }, err: { (error) in
            self.handleError(error: error)
            Utility.sharedInstance.hideActivityIndicator(view: self.view)
        })
    }
    
    func fetchOrUpdateUser(uid: String, values: [String: AnyObject]) {
        Cloud.sharedInstance.fetchUserData(userId: uid, completion: { (user) in
            Utility.sharedInstance.writeUserDataToArchiver(user: user, completion: {
                Utility.sharedInstance.hideActivityIndicator(view: self.view)
                self.performSegue(withIdentifier: "toProfile", sender: self)
            })
        }, err: {
            let user = User(userDictionary: values as [String: AnyObject])
            Cloud.sharedInstance.updateUserInDatabaseWithUID(uid: uid, values: values, completion: { 
                Utility.sharedInstance.writeUserDataToArchiver(user: user, completion: {
                    Utility.sharedInstance.hideActivityIndicator(view: self.view)
                    self.performSegue(withIdentifier: "toProfile", sender: self)
                })
            })
        })
    }
    
    func handleError(error: Error) {
        Utility.sharedInstance.hideActivityIndicator(view: self.view)
        Utility.showAlert(viewController: self, title: "Registration Error", message: "\(error.localizedDescription)", completion: {})
    }
    
    // MARK: - Navigation

     @IBAction func onCancelButton(_ sender: UIButton) {
        Utility.sharedInstance.hideActivityIndicator(view: self.view)
        dismiss(animated: true, completion: nil)
     }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toProfile" {
            let destinationNavigationController = segue.destination as! UINavigationController
            let targetController = destinationNavigationController.topViewController as! ProfileViewController
            //targetController.user = self.user
            targetController.firstTimeRegisteringUser = true
        }
    }
}

