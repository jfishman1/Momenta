//
//  GroupDetailViewController.swift
//  humble
//
//  Created by Jonathon Fishman on 10/24/17.
//  Copyright © 2017 GoYoJo. All rights reserved.
//

import UIKit
import Firebase

class PostDetailViewController: UIViewController, PostDataModelDelegate {
    
    func didReceivePostDataUpdate(post: Post, comments: [Comment]) {
        if let currentUserData = userData {
            self.post = post
            self.viewModel = PostDetailViewModel(post: post, comments: comments, currentUserData: currentUserData, postDetailVC: self)
        } else {
            print("PostDetailViewController failed to retrieve currentUserData from archiver")
        }
    }
    
    var userData: User?
    var post: Post?
    var missingImage: UIImage?
    
    var viewModel: PostDetailViewModel? {
        didSet {
            tableView?.dataSource = viewModel
            tableView?.delegate = viewModel
            self.tableView?.reloadData()
        }
    }
    var dataModel: PostDataModel?

    @IBOutlet weak var tableView: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.delegate = self
        dataModel?.delegate = self
        dataModel?.requestPostData()
        viewModel?.setupData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        navigationController?.hidesBarsOnSwipe = true
//        navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getDataUpdate), name: NSNotification.Name(rawValue: userDataManagerDidUpdateCurrentUserNotification), object: nil)
        
        UserDataManager.sharedInstance.requestCurrentUserData()
        
        if let indexPath = tableView?.indexPathForSelectedRow {
            tableView?.deselectRow(at: indexPath, animated: animated)
        }
    }
    
    @objc private func getDataUpdate() {
        if let userData = UserDataManager.sharedInstance.currentUserData {
            self.userData = userData
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.hidesBarsOnSwipe = false
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: userDataManagerDidUpdateCurrentUserNotification), object: nil)
    }
    
    @IBAction func onBackButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func reactToSupportButtonClick() {
        if let postCreatorId = post?.creatorId, let currentUserId = userData?.userId, let postId = post?.postId {
            Cloud.sharedInstance.addSupporterToPostCreator(postCreatorId: postCreatorId, currentUserId: currentUserId, completion: {
                Cloud.sharedInstance.updatePostSupporters(postId: postId, supporterId: currentUserId, completion: {
                    Cloud.sharedInstance.addSupporterToGroup(postId: postId, currentUserId: currentUserId, completion: {
                    })
                })
            })
        }
    }
    
    func reactToMomentumButtonClick() {
        self.performSegue(withIdentifier: "toAddComment", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddComment" {
            let nextVC = segue.destination as! AddCommentViewController
            nextVC.post = self.post!
        }
    }
    
    @IBAction func unwindToPostDetailVC(segue: UIStoryboardSegue) {
        if segue.source.isKind(of: AddCommentViewController.self) {
            let prevVC = segue.source as! AddCommentViewController
            self.missingImage = prevVC.selectedImageFromPicker
            viewModel?.isCurrentPostSupporter = true
        }
    }
}

