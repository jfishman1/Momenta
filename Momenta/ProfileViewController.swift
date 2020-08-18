//
//  ProfileViewController.swift
//  humble
//
//  Created by Jonathon Fishman on 2/18/18.
//  Copyright © 2018 GoYoJo. All rights reserved.
//

import UIKit
import OneSignal

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var user: User?
    var attributes = [String]()
    var firstTimeRegisteringUser = false
    var isComingBackToProfileVC = false
    
    var postIdsArray = [String]()
    var commentIdsArray = [String]()
    
    var dataModel = ProfileDataModel()
    
    var viewModel: ProfileViewModel? {
        didSet {
            tableView?.dataSource = viewModel
            tableView?.delegate = viewModel
            viewModel!.profileVC = self
            tableView.reloadData()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getDataUpdate), name: NSNotification.Name(rawValue: userDataManagerDidUpdateCurrentUserNotification), object: nil)
        UserDataManager.sharedInstance.requestCurrentUserData()
    }
    @objc private func getDataUpdate() {
        if let currentUserData = UserDataManager.sharedInstance.currentUserData {
            self.user = currentUserData
            self.attributes = currentUserData.attributes ?? []
            fetchPostAndCommentIds()
        }
    }
    
    private func fetchPostAndCommentIds() {
        self.postIdsArray.removeAll()
        if let postIds = user?.posts?.keys {
            postIdsArray = Array(postIds)
        }
        self.commentIdsArray.removeAll()
        if let commentIds = user?.comments?.keys {
            commentIdsArray = Array(commentIds)
        }
        dataModel.postIds = postIdsArray
        dataModel.commentIds = commentIdsArray
        dataModel.requestProfilePostAndCommentData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: userDataManagerDidUpdateCurrentUserNotification), object: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barStyle = UIBarStyle.black
        viewModel?.delegate = self
        dataModel.delegate = self
        setupNavigationItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
        let isSubscribed = status.subscriptionStatus.subscribed
        print("isSubscribed = \(isSubscribed)")
        if isSubscribed == false {
            OneSignal.addTrigger("unsubscribed", withValue: "true")
        }
    }
    
    func setupNavigationItems() {
        let dismissImage = UIImage(named: "CancelButtonWhite")?.withRenderingMode(.alwaysOriginal)
        let dismissBarButtonItem = UIBarButtonItem(image: dismissImage, style: .plain, target: self, action: #selector(leaveProfile))
        navigationItem.leftBarButtonItem = dismissBarButtonItem
        let settingsImage = UIImage(named: "Wheel")?.withRenderingMode(.alwaysOriginal)
        let settingsBarButtonItem = UIBarButtonItem(image: settingsImage, style: .plain, target: self, action: #selector(goToSettings))
        navigationItem.rightBarButtonItem = settingsBarButtonItem
    }
    
    @IBAction func onEditProfileButton(_ sender: UIButton) {
        isComingBackToProfileVC = true
        performSegue(withIdentifier: "toEditProfile", sender: self)
    }
    func segueToEditProfile() {
        isComingBackToProfileVC = true
        performSegue(withIdentifier: "toEditProfile", sender: self)
    }
    
    func handleSave() {
        Utility.sharedInstance.showActivityIndicator(view: self.view)
        if firstTimeRegisteringUser == true {
            self.leaveProfile()
        } else {
            leaveProfile()
        }
    }
    
    @IBAction func unwindFromEditProfile(_ segue: UIStoryboardSegue) {
        if segue.source.isKind(of: EditProfileViewController.self) {
            let prevVC = segue.source as! EditProfileViewController
            self.attributes = prevVC.attributesArray
            self.tableView.reloadData()
        }
    }
    
    @objc func goToSettings() {
        isComingBackToProfileVC = true
        self.performSegue(withIdentifier: "goToSettings", sender: self)
    }
    
    @objc func leaveProfile() {
        Utility.sharedInstance.hideActivityIndicator(view: self.view)
        if firstTimeRegisteringUser == true {
            self.performSegue(withIdentifier: "toMain", sender: self)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension ProfileViewController: ProfileDataModelDelegate {
    func didReceiveProfileDataUpdate(posts: [Post], comments: [Comment]) {
        self.viewModel = ProfileViewModel(user: user!, posts: posts, comments: comments, attributes: self.attributes)
        tableView.reloadData()
    }
    
    
}
