//
//  ProfileViewModel.swift
//  humble
//
//  Created by Jonathon Fishman on 2/18/18.
//  Copyright © 2018 GoYoJo. All rights reserved.
//

import Foundation
import UIKit

protocol ProfileViewModelDelegate: class {
    func apply(changes: SectionChanges)
}

class ProfileViewModel: NSObject {
    fileprivate var items = [ProfileViewModelItem]()
    weak var delegate: ProfileViewModelDelegate?
    weak var profileVC: ProfileViewController?
    var user: User?
    var attributesArray: [String]?
    var posts: [Post]?
    var comments: [Comment]?
    var isCurrentUser = true
    
    init(user: User, posts: [Post], comments: [Comment], attributes: [String]) {
        super.init()
        self.posts?.removeAll()
        self.comments?.removeAll()
        self.attributesArray?.removeAll()
        self.user = user
        self.posts = posts
        self.comments = comments
        self.attributesArray = attributes
        setupData()
    }
    
    private func flatten(items: [ProfileViewModelItem]) -> [ReloadableSection<CellItem>] {
        let reloadableItems = items
            .enumerated()
            .map { ReloadableSection(key: $0.element.type.rawValue, value: $0.element.cellItems
                .enumerated()
                .map { ReloadableCell(key: $0.element.id, value: $0.element, index: $0.offset)  }, index: $0.offset) }
        return reloadableItems
    }
    
    private func setup(newItems: [ProfileViewModelItem]) {
        let oldData = flatten(items: items)
        let newData = flatten(items: newItems)
        let sectionChanges = DiffCalculator.calculate(oldItems: oldData, newItems: newData)
        
        items = newItems
        delegate?.apply(changes: sectionChanges)
    }
    
    func setupData() {
        self.items.removeAll()
        var newItems = [ProfileViewModelItem]()
        
        guard let firstName = user?.firstName else { return }
        let lastName = user?.lastName ?? ""
        let profileImageUrl = user?.bigProfileImageUrl ?? ""
        let userName = "\(firstName) \(lastName)"
        let nameAndPictureItem = ProfileViewModelNameItem(profileImageUrl: profileImageUrl, userName: userName, isCurrentUser: isCurrentUser)
        newItems.append(nameAndPictureItem)
        
        let actionsCount = user?.posts?.count ?? 0
        
        let momentaCount = user?.comments?.count ?? 0
        
        let supportersCount = user?.supporters?.count ?? 0
        
        let statsItem = ProfileViewModelStatsItem(actionsCount: actionsCount, momentaCount: momentaCount, supportersCount: supportersCount)
        newItems.append(statsItem)
        
        let attributes = user?.attributes ?? ["Add some items you support"]//["Acceptance"]
        self.attributesArray = attributes
        let attributesItem = ProfileViewModelAttributesItem(attributes: attributes)
        newItems.append(attributesItem)
        
        if !posts!.isEmpty {
            let createdActionsItem = ProfileViewModelActionsItem(actions: posts!)
            newItems.append(createdActionsItem)
        }
        
        if !comments!.isEmpty {
            let createdMomentaItem = ProfileViewModelMomentumItem(momenta: comments!)
            newItems.append(createdMomentaItem)
        }
        setup(newItems: newItems)
    }
}

extension ProfileViewModel: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].cellItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.section]
        switch item.type {
        case .nameAndPicture:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "nameAndPictureCell", for: indexPath) as? NameAndPictureCell {
                cell.item = item
                cell.selectionStyle = .none
                return cell
            }
        case .stats:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "statsCell", for: indexPath) as? StatsCell {
                cell.item = item
                cell.selectionStyle = .none
                return cell
            }
        case .attributes:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "attributesCell", for: indexPath) as? AttributesCell {
                cell.attributeName.removeAll()
                cell.attributeLabel1.isHidden = true
                cell.attributeLabel2.isHidden = true
                cell.attributeLabel3.isHidden = true
                cell.attributeLabel4.isHidden = true
                cell.attributeLabel5.isHidden = true
                cell.attributeLabel6.isHidden = true
                cell.attributeLabel7.isHidden = true
                cell.attributeLabel8.isHidden = true
                cell.item = item
                cell.setupLabels()
                cell.selectionStyle = .none
                
                return cell
            }
        case .action:
            if let item = item as? ProfileViewModelActionsItem, let cell = tableView.dequeueReusableCell(withIdentifier: "myActionsCell", for: indexPath) as? MyActionsCell {
                let action = item.actions[indexPath.row]
                cell.item = action
                cell.selectionStyle = .none
                return cell
            }
        case .momentum:
            if let item = item as? ProfileViewModelMomentumItem, let cell = tableView.dequeueReusableCell(withIdentifier: "myMomentaCell", for: indexPath) as? MyMomentaCell {
                let momentum = item.momenta[indexPath.row]
                cell.item = momentum
                cell.selectionStyle = .none
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isCurrentUser == true {
            switch items[indexPath.section].type {
            case .nameAndPicture:
                profileVC!.segueToEditProfile()
            case .attributes:
                profileVC!.segueToEditProfile()
            default:
                return
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        } else if section == 1 {
            return nil
        } else {
            return items[section].sectionTitle
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if section == 0 {
            view.isHidden = true
        } else if section == 1 {
            view.isHidden = true
        } else {
            view.tintColor = .white
            let headerView: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
            headerView.textLabel?.textColor = Utility.sharedInstance.mainGreen
        }
    }
}

extension ProfileViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = items[indexPath.section]
        switch item.type {
        case .nameAndPicture:
            return 200
        case .stats:
            return 100
        case .attributes:
            let attributesCount = attributesArray!.count
            if attributesCount <= 2 {
                return 72
            } else if attributesCount <= 4 {
                return 112
            } else if attributesCount <= 6 {
                return 152
            } else {
                return 192
            }
        case .action:
            return 84
        case .momentum:
            return 84
        }
    }
}

enum ProfileViewModelItemType: String {
    case nameAndPicture = "nameAndPicture"
    case stats = "stats"
    case attributes = "attributes"
    case action = "action"
    case momentum = "momentum"
}

protocol ProfileViewModelItem {
    var type: ProfileViewModelItemType { get }
    var cellItems: [CellItem] { get }
    var sectionTitle: String { get }
}

class ProfileViewModelNameItem: ProfileViewModelItem {
    var type: ProfileViewModelItemType {
        return .nameAndPicture
    }
    var sectionTitle: String {
        return "Main Info"
    }
    var cellItems: [CellItem] {
        return[CellItem(value: "\(profileImageUrl), \(userName), \(isCurrentUser)", id: sectionTitle)]
    }
    
    var profileImageUrl: String
    var userName: String
    var isCurrentUser: Bool
    
    init(profileImageUrl: String, userName: String, isCurrentUser: Bool) {
        self.profileImageUrl = profileImageUrl
        self.userName = userName
        self.isCurrentUser = isCurrentUser
    }
}

class ProfileViewModelStatsItem: ProfileViewModelItem {
    var type: ProfileViewModelItemType {
        return .stats
    }
    var sectionTitle: String {
        return "My Stats"
    }
    var cellItems: [CellItem] {
        return[CellItem(value: "\(actionsCount), \(momentaCount), \(supportersCount)", id: sectionTitle)]
    }
    
    var actionsCount: Int
    var momentaCount: Int
    var supportersCount: Int
    
    init(actionsCount: Int, momentaCount: Int, supportersCount: Int) {
        self.actionsCount = actionsCount
        self.momentaCount = momentaCount
        self.supportersCount = supportersCount
    }
}

class ProfileViewModelAttributesItem: ProfileViewModelItem {
    var type: ProfileViewModelItemType {
        return .attributes
    }
    var sectionTitle: String {
        return "Interests"
    }
    var cellItems: [CellItem] {
        return [CellItem(value: "\(attributes)", id: sectionTitle)]
    }
    var attributes: [String]
    
    init(attributes: [String]) {
        self.attributes = attributes
    }
}

class ProfileViewModelActionsItem: ProfileViewModelItem {
    var type: ProfileViewModelItemType {
        return .action
    }
    var sectionTitle: String {
        return "Actions"
    }
    var cellItems: [CellItem] {
        return actions
            .map { CellItem(value: $0.postDescription!, id: $0.postImageUrl ?? "") }
    }
    var actions: [Post]
    init(actions: [Post]) {
        self.actions = actions
    }
}

class ProfileViewModelMomentumItem: ProfileViewModelItem {
    var type: ProfileViewModelItemType {
        return .momentum
    }
    var sectionTitle: String {
        return "Momenta"
    }
    var cellItems: [CellItem] {
        return momenta
            .map { CellItem(value: $0.comment!, id: $0.commentImageUrl ?? "") }
    }
    var momenta: [Comment]
    init(momenta: [Comment]) {
        self.momenta = momenta
    }
}

























