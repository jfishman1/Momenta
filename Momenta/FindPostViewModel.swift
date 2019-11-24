//
//  FindPostViewModel.swift
//  humble
//
//  Created by Jonathon Fishman on 3/31/18.
//  Copyright © 2018 GoYoJo. All rights reserved.
//

import Foundation
import UIKit

class FindPostViewModel: NSObject {
    
    var items = [FindPostModelItem]()
    var posts = [Post]()
    var selectedPostId: String?
    var findPostVC: FindPostViewController?
    let currentUserId = UserDataManager.sharedInstance.currentUserData?.userId ?? ""
    
    init(posts: [Post], findPostVC: FindPostViewController) {
        super.init()
        self.posts = posts
        self.findPostVC = findPostVC
        setupViewModel()
    }
    
    func setupViewModel() {
        for post in posts {
            guard let postId = post.postId else {
                return
            }
            let supportersCount = post.supporterIds?.count ?? 0
            let regularPostData = RegularPostModel(postId: postId, creatorName: post.creatorName ?? "Jon", creatorImageUrl: post.creatorImageUrl ?? "SmallProfileDefault", category: post.category ?? "Random", postDescription: post.postDescription ?? "", supportersCount: supportersCount, momentumCount: post.momentumCount ?? 0)
            if post.postImageUrl == "" && post.postText == "" {
                let regularPostItem = FindPostModelRegularPostItem(regularPostData: regularPostData)
                items.append(regularPostItem)
            } else if post.postImageUrl != "" {
                let postImageUrl = post.postImageUrl ?? "GroupPic1"
                let imagePostItem = FindPostModelImagePostItem(regularPostData: regularPostData, postImageUrl: postImageUrl)
                items.append(imagePostItem)
            } else if post.postText != "" {
                let postText = post.postText ?? ""
                let postTextItem = FindPostModelTextPostItem(regularPostData: regularPostData, postText: postText)
                items.append(postTextItem)
            }
        }
    }
    
    func reportPost(postId: String, postCreatorName: String, reporterId: String) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let reportAction = UIAlertAction(title: "Report", style: .destructive, handler: {
            (alert: UIAlertAction) -> Void in
            Utility.sharedInstance.reportPostAlert(viewController: self.findPostVC!, postId: postId, postCreatorName: postCreatorName, reporterId: reporterId)
        })
        alertController.addAction(reportAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        findPostVC!.present(alertController, animated: true, completion: nil)
    }
}

extension FindPostViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        switch item.type {
        case .regularPost:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostTableViewCell {
                cell.item = item
                cell.optionsButtonClickCallback = {[weak self] postId, postCreatorName in
                    self?.reportPost(postId: postId, postCreatorName: postCreatorName, reporterId: (self?.currentUserId)!)
                }
                return cell
            }
        case .imagePost:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ImagePostCell", for: indexPath) as? ImagePostTableViewCell {
                cell.item = item
                cell.optionsButtonClickCallback = {[weak self] postId, postCreatorName in
                    self?.reportPost(postId: postId, postCreatorName: postCreatorName, reporterId: (self?.currentUserId)!)
                }
                return cell
            }
        case .textPost:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "TextPostCell", for: indexPath) as? TextPostTableViewCell {
                cell.item = item
                cell.optionsButtonClickCallback = {[weak self] postId, postCreatorName in
                    self?.reportPost(postId: postId, postCreatorName: postCreatorName, reporterId: (self?.currentUserId)!)
                }
                return cell
            }
        }
        return UITableViewCell()
    }
}

extension FindPostViewModel: UITableViewDelegate {
    func estimateHeightForText(text: String) -> CGRect {
        let width = UIScreen.main.bounds.width - 30
        let size = CGSize(width: width, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue", size: 13.0)!], context: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat
        let item = items[indexPath.row]
        let text = item.regularPostData.postDescription
        height = estimateHeightForText(text: text).height + 125
        switch item.type {
        case .regularPost:
            return height
        case .imagePost:
            return height + 290
        case .textPost:
            return height + 160
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        let postId = item.regularPostData.postId
        self.selectedPostId = postId
    
        findPostVC!.performSegue(withIdentifier: "toPostDetail", sender: findPostVC)
//        switch item.type {
//        case .regularPost:
//            if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostTableViewCell {
//                cell.item = item
//                return cell
//            }
//        case .imagePost:
//            if let cell = tableView.dequeueReusableCell(withIdentifier: "ImagePostCell", for: indexPath) as? ImagePostTableViewCell {
//                cell.item = item
//                return cell
//            }
//        case .textPost:
//            if let cell = tableView.dequeueReusableCell(withIdentifier: "TextPostCell", for: indexPath) as? TextPostTableViewCell {
//                cell.item = item
//                return cell
//            }
//        }
    }
}


enum FindPostModelItemType {
    case regularPost
    case imagePost
    case textPost
}

protocol FindPostModelItem {
    var type: FindPostModelItemType { get }
    var regularPostData: RegularPostModel { get }
}

struct RegularPostModel {
    var postId: String
    var creatorName: String
    var creatorImageUrl: String
    var category: String
    var postDescription: String
    var supportersCount: Int
    var momentumCount: Int
    
    init(postId: String, creatorName: String, creatorImageUrl: String, category: String, postDescription: String, supportersCount: Int, momentumCount: Int) {
        self.postId = postId
        self.creatorName = creatorName
        self.creatorImageUrl = creatorImageUrl
        self.category = category
        self.postDescription = postDescription
        self.supportersCount = supportersCount
        self.momentumCount = momentumCount
    }
}

class FindPostModelRegularPostItem: FindPostModelItem {
    var type: FindPostModelItemType {
        return .regularPost
    }
    var regularPostData: RegularPostModel
    init(regularPostData: RegularPostModel) {
        self.regularPostData = regularPostData
    }
}

class FindPostModelImagePostItem: FindPostModelItem {
    var type: FindPostModelItemType {
        return .imagePost
    }
    var regularPostData: RegularPostModel
    var postImageUrl: String
    
    init(regularPostData: RegularPostModel, postImageUrl: String) {
        self.regularPostData = regularPostData
        self.postImageUrl = postImageUrl
    }
}

class FindPostModelTextPostItem: FindPostModelItem {
    var type: FindPostModelItemType {
        return .textPost
    }
    var regularPostData: RegularPostModel
    var postText: String
    
    init(regularPostData: RegularPostModel, postText: String) {
        self.regularPostData = regularPostData
        self.postText = postText
    }
}

