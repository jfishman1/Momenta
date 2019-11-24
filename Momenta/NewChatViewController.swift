//
//  NewChatTableViewController.swift
//  humble
//
//  Created by Jonathon Fishman on 10/5/17.
//  Copyright © 2017 GoYoJo. All rights reserved.
//

import UIKit

class NewChatViewController: UIViewController {
    
    var collectionView: UICollectionView!
    var currentUser: User?
    
    var chatCollectionController: ChatCollectionViewController?
    let cellId = "cellId"
    
    var users = [User]()
    var blockedUserIds = [String]()
    
    let layout = UICollectionViewLayout()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(PrivateChatCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
        navigationItem.title = "My Supporters"
        navigationController?.navigationBar.tintColor = .darkGray
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        fetchBlockedUserIds()
        fetchUser()
    }
    
    func fetchUser() {
        guard let uid = currentUser?.userId else { return }
        Cloud.sharedInstance.fetchCurrentUserSupporters(uid: uid, completion: { user in
            self.users.append(user)
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        })
    }
    
    func fetchBlockedUserIds() {
        guard let uid = currentUser?.userId else { return }
        Cloud.sharedInstance.fetchBlockedUserIds(uid: uid, completion: { blockedUserId in
            self.blockedUserIds.append(blockedUserId)
        })
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        // by default the cells will show as small separated squares
        layout.minimumLineSpacing = 0 // handles space between top and bottom cells
        layout.minimumInteritemSpacing = 0 // handles space between cells left and right
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.delegate = self // letting compiler know the delegate will come from this ViewController class
        collectionView.dataSource = self //
        view.addSubview(collectionView)
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
}

extension NewChatViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PrivateChatCollectionViewCell
        let user = users[indexPath.row]
        cell.nameTextLabel.text = user.firstName
        
        if let profileImageUrl = user.smallProfileImageUrl {
            if profileImageUrl != "" {
                cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
            } else {
                cell.profileImageView.image = UIImage(named: "SmallProfileDefault")
            }
        }
        
        // TODO: Set detail label to Blocked
        for userId in blockedUserIds {
            if user.userId == userId {
                cell.detailLabel.text = "Blocked User"
            }
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout methods
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: 72)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dismiss(animated: true, completion: {
            //print("dismiss completed")
            let user = self.users[indexPath.row]
            self.chatCollectionController?.showChatLogControllerForUser(user: user)
            // messagesController will be nil bc we did not set it to any object yet,
            // we want to set messagesController every time we click the new chat button
            // when we click the new chat button aka rightBarButton "new_message_icon" we call handleNewMessage
            
        })
        
    }
    
}

