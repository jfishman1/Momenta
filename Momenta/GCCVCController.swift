//
//  GCCVCController.swift
//  humble
//
//  Created by Jonathon Fishman on 10/8/17.
//  Copyright © 2017 GoYoJo. All rights reserved.
//

import UIKit
import Firebase

// GroupChatCollectionViewCellController
class GCCVCController: BaseCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    var posts = [Post]()
    var postIds = [String]()
    // true data storage
    var groupsDictionary = [String: Post]()
    
    let cellId = "groupCellId"
    
    override func setupViews() {
        addSubview(collectionView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: collectionView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: collectionView)
        collectionView.register(GroupChatCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        observeGroups()
    }
    
    func observeGroups() {
        posts.removeAll()
        groupsDictionary.removeAll()
        collectionView.reloadData()

        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = Database.database().reference().child("users").child(uid).child("groups")
        ref.observe(.childAdded, with: { (snapshot) in
            //print(snapshot) // shows the groupIds in the users node
            let postId = snapshot.key
            self.postIds.append(postId)
            self.fetchPostWithPostId(postId: postId)
        }, withCancel: nil)

        // deleting a group from an outside source (from DB itself)
        ref.observe(.childRemoved, with: { (snapshot) in
            //print(snapshot.key)
            //print(self.groupsDictionary)
            self.groupsDictionary.removeValue(forKey: snapshot.key)
            self.attemptReloadOfCollectionView()
        }, withCancel: nil)
    }
    
    fileprivate func fetchPostWithPostId(postId: String) {
        let groupReference = Database.database().reference().child("posts").child(postId)

        groupReference.observeSingleEvent(of: .value, with: { (snapshot) in
            //print(snapshot)
            if let dictionary = snapshot.value as? [String: AnyObject] {
                //print(dictionary)
                let post = Post(postDictionary: dictionary)
                //self.posts.append(post)
                self.groupsDictionary[postId] = post
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
        self.posts = Array(self.groupsDictionary.values)
        self.posts.sort(by: { (post1, post2) -> Bool in
            return (post1.supporterIds?.count) ?? 0 > (post2.supporterIds?.count) ?? 0
        })
        
        DispatchQueue.main.async(execute: {
            self.collectionView.reloadData()
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! GroupChatCollectionViewCell
        
        //cell.group = posts[indexPath.item]
        cell.group = posts[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width, height: 103)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        let postId = post.postId!
        let ref = Database.database().reference().child("posts").child(postId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            //print(snapshot) //will show dictionary when row is clicked
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            let group = Post(postDictionary: dictionary)
            self.delegate?.selectedGroupCell(group: group)

        }, withCancel: nil)
    }
}
