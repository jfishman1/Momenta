//
//  GroupDetialViewModel.swift
//  humble
//
//  Created by Jonathon Fishman on 10/24/17.
//  Copyright © 2017 GoYoJo. All rights reserved.
//

import Foundation
import UIKit

protocol PostDetailViewModelDelegate: class {
    func apply(changes: SectionChanges)
}

class PostDetailViewModel: NSObject {
    fileprivate var items = [PostDetailViewModelItem]()
    weak var delegate: PostDetailViewModelDelegate?
    
    var isPostCreator = false
    var post: Post?
    var commentsArray = [Comment]()
    var imageComments = [Comment]()
    var textComments = [Comment]()
    var supporterIds = [String]()
    var currentUserData: User?
//    var postCreatorUserId: String? {
//        didSet {
//            print("postCreatorUserId did set!!!!!!!!!!!!!!!!!!!!!!!!!: ", postCreatorUserId!)
//        }
//    }
    var isCurrentPostSupporter = false
    var postDetailVC: PostDetailViewController?
    
    init(post: Post, comments: [Comment], currentUserData: User, postDetailVC: PostDetailViewController) {
        super.init()
        commentsArray.removeAll()
        self.post = post
        self.commentsArray = comments
        self.currentUserData = currentUserData
        self.postDetailVC = postDetailVC
        setupData()
    }
    
    private func flatten(items: [PostDetailViewModelItem]) -> [ReloadableSection<CellItem>] {
        let reloadableItems = items
            .enumerated()
            .map { ReloadableSection(key: $0.element.type.rawValue, value: $0.element.cellItems
                .enumerated()
                .map { ReloadableCell(key: $0.element.id, value: $0.element, index: $0.offset)  }, index: $0.offset) }
        return reloadableItems
    }
    
    private func setup(newItems: [PostDetailViewModelItem]) {
        let oldData = flatten(items: items)
        let newData = flatten(items: newItems)
        let sectionChanges = DiffCalculator.calculate(oldItems: oldData, newItems: newData)
        items = newItems
        delegate?.apply(changes: sectionChanges)
    }
    
    func setupData() {
        self.items.removeAll()
        imageComments.removeAll()
        textComments.removeAll()
        supporterIds.removeAll()
        var newItems = [PostDetailViewModelItem]()
        
        let creatorImageUrl = post?.creatorImageUrl ?? "SmallProfileDefault"
        let creatorName = post?.creatorName ?? "Jon"
        let category = post?.category ?? "Other"
        let postDescription = post?.postDescription ?? "Can't find description at this time... sorry!"
        let postCreatorAndDescription = PostDetailViewModelDescriptionItem(creatorImageUrl: creatorImageUrl, creatorName: creatorName, category: category, postDescription: postDescription)
        
        newItems.append(postCreatorAndDescription)
        
        if let postText = post?.postText {
            if postText != "" {
                let postTextItem = PostDetailViewModelTextItem(postText: postText)
                newItems.append(postTextItem)
            }
        }
        
        if let postImageUrl = post?.postImageUrl {
            if postImageUrl != "" {
                let postImageItem = PostDetailViewModelImageItem(postImageUrl: postImageUrl)
                newItems.append(postImageItem)
            }
        }
        
        if let postSupporterIds = post?.supporterIds {
            for userId in postSupporterIds.keys {
                if currentUserData!.userId! == userId {
                    isCurrentPostSupporter = true
                }
            }
        }
        
        let supportersCount = post?.supporterIds?.count ?? 0
        let momentumCount = post?.momentumCount ?? 0
        let actionsItem = PostDetailViewModelActionsItem(supportersCount: supportersCount, momentumCount: momentumCount, isCurrentPostSupporter: isCurrentPostSupporter)
        
        newItems.append(actionsItem)
        
        let comments = commentsArray
        if !comments.isEmpty {
            for comment in comments {
                if comment.commentImageUrl == "" {
                    textComments.append(comment)
                } else {
                    imageComments.append(comment)
                }
            }
            if imageComments.count != 0 {
                let imageCommentItem = PostDetailViewModelImageCommentItem(comments: imageComments)
                newItems.append(imageCommentItem)
            }
            if textComments.count != 0 {
                let textCommentsItem = PostDetailViewModelCommentItem(comments: textComments)
                newItems.append(textCommentsItem)
            }
        } else {
            let noCommentsItem = PostDetailNoCommentsItem()
            newItems.append(noCommentsItem)
        }
        setup(newItems: newItems)
        //print("--------------------------------postDetailViewModel items count: \(items.count), items.description: \(items.description)")
    }
    
    func reportComment(commentId: String, commentCreatorName: String, reporterId: String) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let reportAction = UIAlertAction(title: "Report", style: .destructive, handler: {
            (alert: UIAlertAction) -> Void in
            Utility.sharedInstance.reportCommentAlert(viewController: self.postDetailVC!, postId: self.post!.postId!, commentId: commentId, commentCreatorName: commentCreatorName, reporterId: reporterId)
        })
        alertController.addAction(reportAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        postDetailVC?.present(alertController, animated: true, completion: nil)
    }
}


extension PostDetailViewModel: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let count = items.count
        return count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].cellItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = items[indexPath.section]
        switch item.type {
        case .postCreatorAndDescription:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "postDescriptionCell", for: indexPath) as? PostDescriptionCell {
                cell.item = item
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
                return cell
            }
        case .postText:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "postTextCell", for: indexPath) as? PostTextCell {
                cell.item = item
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
                return cell
            }
        case .postImage:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "postImageCell", for: indexPath) as? PostImageCell {
                cell.item = item
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
                return cell
            }
        case .postActions:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "postActionsCell", for: indexPath) as? PostActionsCell {
                cell.selectionStyle = .none
                cell.item = item
                if isCurrentPostSupporter == false {
                    cell.supportButtonClickCallback = { [weak self] in
                        cell.updateSupportersLabelAndButton()
                        self?.postDetailVC?.reactToSupportButtonClick()
                    }
                } else {
                    cell.supportButton?.setTitleColor(.orange, for: .normal)
                    cell.supportersLabel?.textColor = .orange
                }
                cell.momentumButtonClickCallback = { [weak self] in
                    self?.postDetailVC?.reactToMomentumButtonClick()
                }
                return cell
            }
        case .postComments:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "postTextCommentCell", for: indexPath) as? PostTextCommentCell {
                cell.item = textComments[indexPath.row]
                cell.optionsButtonClickCallback = {[weak self] commentId, commentCreatorName in
                    self?.reportComment(commentId: commentId, commentCreatorName: commentCreatorName, reporterId: self!.currentUserData!.userId!)
                }
                return cell
            }
        case .postImageComments:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "postImageCommentCell", for: indexPath) as? PostImageCommentCell {
                cell.missingImage = postDetailVC?.missingImage
                cell.item = imageComments[indexPath.row]
                cell.optionsButtonClickCallback = {[weak self] commentId, commentCreatorName in
                    self?.reportComment(commentId: commentId, commentCreatorName: commentCreatorName, reporterId: self!.currentUserData!.userId!)
                }
                return cell
            }
        case .noComments:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "postNoCommentsCell", for: indexPath) as? PostNoCommentsCell {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                return cell
            }
        }
        return UITableViewCell()
    }
}

extension PostDetailViewModel: UITableViewDelegate {
    func estimateHeightForText(text: String) -> CGRect {
        let width = UIScreen.main.bounds.width - 30
        let size = CGSize(width: width, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue", size: 16.0)!], context: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat
        let item = items[indexPath.section]
        switch item.type {
        case .postCreatorAndDescription:
            if let text = post?.postDescription {
                height = estimateHeightForText(text: text).height + 72
                return height
            } else {
                return 0
            }
        case .postText:
            if let text = post?.postText {
                height = estimateHeightForText(text: text).height
                return height
            } else {
                return 0
            }
        case .postImage:
            return 270
        case .postActions:
            return 72
        case .postComments:
            if let text = textComments[indexPath.row].comment {
                height = estimateHeightForText(text: text).height + 72
                return height
            } else {
                return 72
            }
        case .postImageComments:
            if let text = imageComments[indexPath.row].comment {
                height = estimateHeightForText(text: text).height + 72
            } else {
                height = 72
            }
            if imageComments[indexPath.row].commentImageUrl != nil {
                height += 270
                return height
            } else {
                return height
            }
        case .noComments:
            return 600
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.section]
        var textComment = Comment(commentDictionary: [:])
        var imageComment = Comment(commentDictionary: [:])
        if textComments.count != 0 {
            textComment = textComments[indexPath.row]
        }
        if imageComments.count != 0 {
            imageComment = imageComments[indexPath.row]
        }
        switch item.type {
        case .postCreatorAndDescription:
            return
        case .postText:
            return
        case .postImage:
            return
        case .postActions:
            return
        case .postComments:
            if let userId = textComment.commentCreatorId, let name = textComment.commentorName, let commentDescription = textComment.comment {
                print("comment userId: \(userId), name: \(name), comment: \(commentDescription)")
            } else {
                return
            }
        case .postImageComments:
            if let userId = imageComment.commentCreatorId, let name = imageComment.commentorName, let commentDescription = imageComment.comment {
                print("comment userId: \(userId), name: \(name), comment: \(commentDescription)")
            } else {
                return
            }
        case .noComments:
            return
        }
    }
}


enum PostDetailViewModelItemType: String {
    case postCreatorAndDescription = "postCreatorAndDescription"
    case postText = "postText"
    case postImage = "postImage"
    case postActions = "postActions"
    case postComments = "postComments"
    case postImageComments = "postImageComments"
    case noComments = "noComments"
}

protocol PostDetailViewModelItem {
    var type: PostDetailViewModelItemType { get }
    var cellItems: [CellItem] { get }
    //var rowCount: Int { get }
    var sectionTitle: String { get }
}

struct CellItem: Equatable {
    var value: CustomStringConvertible // conform to Equatable protocol through description property
    var id: String
    
    static func ==(lhs: CellItem, rhs: CellItem) -> Bool {
        return lhs.id == rhs.id && lhs.value.description == rhs.value.description
    }
}

// defaults
extension PostDetailViewModelItem {
    var rowCount: Int {
        return 1
    }
}

// create first ViewModelItem
class PostDetailViewModelDescriptionItem: PostDetailViewModelItem {
    var type: PostDetailViewModelItemType {
        return .postCreatorAndDescription
    }
    
    var sectionTitle: String {
        return "Post Description"
    }
    
    var cellItems: [CellItem] {
        return[CellItem(value: "\(creatorImageUrl), \(creatorName), \(category), \(postDescription)", id: sectionTitle)]
    }
    
    var creatorImageUrl: String
    var creatorName: String
    var category: String
    var postDescription: String
    
    init(creatorImageUrl: String, creatorName: String, category: String, postDescription: String) {
        self.creatorImageUrl = creatorImageUrl
        self.creatorName = creatorName
        self.category = category
        self.postDescription = postDescription
    }
}

class PostDetailViewModelTextItem: PostDetailViewModelItem {
    var type: PostDetailViewModelItemType {
        return .postText
    }
    var sectionTitle: String {
        return "Post Text"
    }
    var cellItems: [CellItem] {
        return[CellItem(value: postText, id: sectionTitle)]
    }
    var postText: String
    init(postText: String) {
        self.postText = postText
    }
}

class PostDetailViewModelImageItem: PostDetailViewModelItem {
    var type: PostDetailViewModelItemType {
        return .postImage
    }
    var sectionTitle: String {
        return "Post Image"
    }
    var cellItems: [CellItem] {
        return[CellItem(value: postImageUrl, id: sectionTitle)]
    }
    var postImageUrl: String
    init(postImageUrl: String) {
        self.postImageUrl = postImageUrl
    }
}

class PostDetailViewModelActionsItem: PostDetailViewModelItem {
    var type: PostDetailViewModelItemType {
        return .postActions
    }
    var sectionTitle: String {
        return "Make an action"
    }
    var cellItems: [CellItem] {
        return[CellItem(value: "\(supportersCount), \(momentumCount), \(isCurrentPostSupporter)", id: sectionTitle)]
    }
    var supportersCount: Int
    var momentumCount: Int
    var isCurrentPostSupporter: Bool
    init(supportersCount: Int, momentumCount: Int, isCurrentPostSupporter: Bool) {
        self.supportersCount = supportersCount
        self.momentumCount = momentumCount
        self.isCurrentPostSupporter = isCurrentPostSupporter
    }
}

class PostDetailViewModelCommentItem: PostDetailViewModelItem {
    var type: PostDetailViewModelItemType {
        return .postComments
    }
    var sectionTitle: String {
        return "Comments"
    }
    var cellItems: [CellItem] {
        return comments
            .map { CellItem(value: $0, id: $0.commentId!)}//$0.comment!)}
    }
    
    var comments: [Comment]
    init(comments: [Comment]) {
        self.comments = comments
    }
}

class PostDetailViewModelImageCommentItem: PostDetailViewModelItem {
    var type: PostDetailViewModelItemType {
        return .postImageComments
    }
    var sectionTitle: String {
        return "Image Comments"
    }
    var cellItems: [CellItem] {
        return comments
            .map { CellItem(value: $0, id: $0.commentId!)}//$0.commentImageUrl!)}
    }
    
    var comments: [Comment]
    
    init(comments: [Comment]) {
        self.comments = comments
    }
}

class PostDetailNoCommentsItem: PostDetailViewModelItem {
    var type: PostDetailViewModelItemType {
        return .noComments
    }
    var sectionTitle: String {
        return "No Comments"
    }
    var cellItems: [CellItem] {
        return[CellItem(value:"", id: sectionTitle)]
    }
    init() {}
}

