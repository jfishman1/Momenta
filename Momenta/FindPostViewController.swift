//
//  FindPostViewController.swift
//  humble
//
//  Created by Jonathon Fishman on 3/31/18.
//  Copyright © 2018 GoYoJo. All rights reserved.
//

import UIKit
import OneSignal

class FindPostViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView?
    
    //var userLoggedIn = false
    var userData = [User]()
    var posts = [Post]()
    var reportedPostIds = [String]()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.orange
        return refreshControl
    }()
    
    var viewModel: FindPostViewModel? {
        didSet {
            tableView?.dataSource = viewModel
            tableView?.delegate = viewModel
            self.tableView?.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getDataUpdate), name: NSNotification.Name(rawValue: userDataManagerDidUpdateCurrentUserNotification), object: nil)
        UserDataManager.sharedInstance.requestCurrentUserData()
    }
    @objc func getDataUpdate() {
        if let userData = UserDataManager.sharedInstance.currentUserData {
            if userData.userId != nil {
                setupNavigationItems(userData: userData)
            } else {
                handleLogout()
            }
        } else {
            handleLogout()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: userDataManagerDidUpdateCurrentUserNotification), object: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView?.backgroundColor = UIColor(r: 220, g: 224, b: 226)
        if #available(iOS 10.0, *) {
            tableView?.refreshControl = refreshControl
        } else {
            tableView?.addSubview(refreshControl)
        }

        checkIfUserIsLoggedIn()
        // setup tabbar delegate for create tab
        self.tabBarController?.delegate = UIApplication.shared.delegate as? UITabBarControllerDelegate
        navigationController?.navigationBar.barStyle = UIBarStyle.black
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.posts.removeAll()
        fetchPosts()

        if let deviceState = OneSignal.getDeviceState() {
            let userId = deviceState.userId
            print("OneSignal Push Player ID: ", userId ?? "called too early, not set yet")
            let subscribed = deviceState.isSubscribed
            print("Device is subscribed: ", subscribed)
            let hasNotificationPermission = deviceState.hasNotificationPermission
            print("Device has notification permissions enabled: ", hasNotificationPermission)
            let notificationPermissionStatus = deviceState.notificationPermissionStatus
            print("Device's notification permission status: ", notificationPermissionStatus.rawValue)
            let pushToken = deviceState.pushToken
            print("Device Push Token Identifier: ", pushToken ?? "no push token, not subscribed")
        }
    }
    
    func fetchPosts() {
        self.posts.removeAll()
        self.reportedPostIds.removeAll()
        Cloud.sharedInstance.fetchReportedPostIds(completion: { postId in
            self.reportedPostIds.append(postId)
        }, err: { error in
            print("Error: ", error)
        })
        Cloud.sharedInstance.fetchAllPostsData(completion: { post in
            if !self.reportedPostIds.contains(post.postId!) {
                self.posts.append(post)
                self.viewModel = FindPostViewModel(posts: self.posts.reversed(), findPostVC: self)
            }
        }, err: { (error) in
            print("Error: ", error)
        })
        self.tableView?.reloadData()
    }
    
    @objc func handleRefresh() {
        fetchPosts()
        self.refreshControl.endRefreshing()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPostDetail" {
            let dataModel = PostDataModel()
//            if let postId = viewModel?.selectedPostId {
//                dataModel.postId = postId
//            } else {
//                dataModel.postId = pushNotificationPostId
//            }
            dataModel.postId = viewModel?.selectedPostId!
            let nextVC = segue.destination as! PostDetailViewController
            nextVC.dataModel = dataModel
        }
    }
    
    func setupNavigationItems(userData: User) {
        let button = UIButton(type: .custom) as UIButton
        button.addTarget(self, action: #selector(goToProfile), for: UIControl.Event.touchUpInside)
        navigationItem.leftBarButtonItem = navigationItem.setupLeftBarProfileButton(button: button, user: userData)
    }
    @objc func goToProfile() {
        // use to visit own profile
        let profileVC = self.storyboard!.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        let navController = UINavigationController(rootViewController: profileVC)
        navController.navigationBar.barTintColor = Utility.sharedInstance.mainGreen
        navController.navigationBar.isTranslucent = false
        self.present(navController, animated:true, completion: nil)
        
        // use to visit other user's profile
        //let profileVC = self.storyboard!.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        //self.navigationController!.pushViewController(profileVC, animated: true)
    }
    
    // check if user is logged in
    func checkIfUserIsLoggedIn() {
        Cloud.sharedInstance.cacheLogginStatus(completion: { (isUserLoggedIn) in
            if isUserLoggedIn == false {
                self.perform(#selector(self.handleLogout), with: nil, afterDelay: 0)
            } else {
                //self.userLoggedIn = true
            }
        })
    }
    
    @objc func handleLogout() {
        Utility.sharedInstance.logoutAndRemoveUserDefaults()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "FirstViewController") as UIViewController
        OneSignal.logoutEmail()
        self.present(controller, animated: true, completion: nil)
    }
}
