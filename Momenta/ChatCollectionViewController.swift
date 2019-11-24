//
//  ChatViewController.swift
//  humble
//
//  Created by Jonathon Fishman on 10/3/17.
//  Copyright © 2017 GoYoJo. All rights reserved.
//

import UIKit

protocol TransitioningDelegateForCVCell: class {
    func selectedGroupCell(group: Post)
    func selectedUserCell(user: User)
}

class ChatCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, TransitioningDelegateForCVCell {
    
    // Delegate Method
    func selectedUserCell(user: User) {
        showChatLogControllerForUser(user: user)
    }
    func selectedGroupCell(group: Post) {
        showGroupChatLogControllerForGroup(group: group)
    }
    
    let groupCellId = "groupCellId"
    let privateCellId = "privateCellId"
    
    var currentUser: User?
    
    lazy var chatMenuBar: ChatMenuBar = {
        let cMB = ChatMenuBar()
        cMB.chatCollectionViewController = self
        return cMB
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = true
        NotificationCenter.default.addObserver(self, selector: #selector(getDataUpdate), name: NSNotification.Name(rawValue: userDataManagerDidUpdateCurrentUserNotification), object: nil)
        UserDataManager.sharedInstance.requestCurrentUserData()
        
    }
    @objc private func getDataUpdate() {
        if let userData = UserDataManager.sharedInstance.currentUserData {
            setupNavigationItems(userData: userData)
            currentUser = userData
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: userDataManagerDidUpdateCurrentUserNotification), object: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barStyle = .blackOpaque
        setupCollectionView()
        setupChatMenuBar()
    }

    func setupCollectionView() {
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0
        }
        
        collectionView?.backgroundColor = UIColor.lightGray
        
        collectionView?.register(GCCVCController.self, forCellWithReuseIdentifier: groupCellId)
        collectionView?.register(PCCVCController.self, forCellWithReuseIdentifier: privateCellId)
        
        collectionView?.contentInset = UIEdgeInsetsMake(70, 0, 0, 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(70, 0, 0, 0)
        
        collectionView?.isPagingEnabled = true
    }
    
    func setupNavigationItems(userData: User) {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(goToProfile), for: UIControlEvents.touchUpInside)
        navigationItem.leftBarButtonItem = navigationItem.setupLeftBarProfileButton(button: button, user: userData)
        
        let newChatImage = UIImage(named: "Write")?.withRenderingMode(.alwaysOriginal)
        let newChatBarButtonItem = UIBarButtonItem(image: newChatImage, style: .plain, target: self, action: #selector(handleNewChat))
        navigationItem.rightBarButtonItem = newChatBarButtonItem
    }
    
    @objc func handleNewChat() {
        let newChatController = NewChatViewController()
        newChatController.chatCollectionController = self
        newChatController.currentUser = self.currentUser
        let navController = UINavigationController(rootViewController: newChatController)
        present(navController, animated: true, completion: nil)
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
    
    func showChatLogControllerForUser(user: User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.toUser = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    func showGroupChatLogControllerForGroup(group: Post) {
        let groupChatLogController = GroupChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        groupChatLogController.group = group
        groupChatLogController.currentUser = currentUser
        navigationController?.pushViewController(groupChatLogController, animated: true)
    }
    
    func scrollToMenuIndex(_ menuIndex: Int) {
        let indexPath = IndexPath(item: menuIndex, section: 0)
        collectionView?.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition(), animated: true)
    }

    private func setupChatMenuBar() {
        view.addSubview(chatMenuBar)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: chatMenuBar)
        view.addConstraintsWithFormat(format: "V:[v0(70)]", views: chatMenuBar)
        chatMenuBar.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        chatMenuBar.horizontalBarLeftAnchorConstraint?.constant = scrollView.contentOffset.x / 2
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let index = targetContentOffset.pointee.x / view.frame.width
        let indexPath = IndexPath(item: Int(index), section: 0)
        chatMenuBar.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition())
    }
    
    // MARK: UICollectionViewController methods
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> BaseCell {
        let identifier: String
        if indexPath.item == 1 {
            identifier = privateCellId
        } else {
            identifier = groupCellId
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! BaseCell
        cell.delegate = self
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout methods
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width, height: view.frame.height - 70)
    }
}
