//
//  PCCVCController.swift
//  humble
//
//  Created by Jonathon Fishman on 10/6/17.
//  Copyright © 2017 GoYoJo. All rights reserved.
//

import UIKit
import Firebase

// PrivateChatCollectionViewCellController
class PCCVCController: BaseCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    var refreshControl: UIRefreshControl!
    
    var messages = [Message]()
    // true data storage
    var messagesDictionary = [String: Message]()
        
    let cellId = "chatCellId"
    
    override func setupViews() {
        self.refreshControl = UIRefreshControl()
        self.collectionView.alwaysBounceVertical = true
        self.refreshControl.tintColor = .orange
        self.refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        self.collectionView.addSubview(refreshControl)
        addSubview(collectionView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: collectionView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: collectionView)
        
        collectionView.register(PrivateChatCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        observeUserMessages()
    }
    
    @objc func refreshData() {
        observeUserMessages()
        self.refreshControl.endRefreshing()
    }
    
    func observeUserMessages() {
        messages.removeAll()
        messagesDictionary.removeAll()
        collectionView.reloadData()
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        var blockedUsers = [String]()
        let blockedUsersRef = Database.database().reference().child("users").child(uid).child("blockedUsers")
        blockedUsersRef.observe(.childAdded, with: { (snapshot) in
            //print(snapshot)
            let blockedUserId = snapshot.key
            //print("blockedUserId: ", blockedUserId)
            blockedUsers.append(blockedUserId)
        })
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            //print(snapshot) // shows the Ids of the messages node
            let userId = snapshot.key
            if !blockedUsers.contains(userId) {
                Database.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                    //print(snapshot) // shows the messages of the user
                    let messageId = snapshot.key
                    self.fetchMessageWithMessageId(messageId: messageId)
                }, withCancel: nil)
            }
        }, withCancel: nil)
        
        // deleting a message from an outside source (from DB itself)
        ref.observe(.childRemoved, with: { (snapshot) in
            //print(snapshot.key)
            //print(self.messagesDictionary)
            
            self.messagesDictionary.removeValue(forKey: snapshot.key)
            self.attemptReloadOfCollectionView()
            
        }, withCancel: nil)
    }
    
    fileprivate func fetchMessageWithMessageId(messageId: String) {
        let messagesReference = Database.database().reference().child("messages").child(messageId)
        
        messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message(messageDictionary: dictionary)
                
                if let chatPartnerId = message.chatPartnerId() {
                    self.messagesDictionary[chatPartnerId] = message
                }
                self.attemptReloadOfCollectionView()
            }
            
        }, withCancel: nil)
    }
    
    var timer: Timer?
    fileprivate func attemptReloadOfCollectionView() {
        self.timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadCollectionView), userInfo: nil, repeats: false)
    }
    
    @objc func handleReloadCollectionView() {
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            
            return (message1.timestamp?.int32Value)! > (message2.timestamp?.int32Value)!
        })
        
        DispatchQueue.main.async(execute: {
            self.collectionView.reloadData()
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PrivateChatCollectionViewCell
        cell.message = messages[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width, height: 72)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            let user = User(userDictionary: dictionary)
            user.userId = chatPartnerId
            self.delegate?.selectedUserCell(user: user)
        }, withCancel: nil)
    }
}
