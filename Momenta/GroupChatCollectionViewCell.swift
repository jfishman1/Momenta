//
//  GroupChatCollectionViewCell.swift
//  humble
//
//  Created by Jonathon Fishman on 10/3/17.
//  Copyright © 2017 GoYoJo. All rights reserved.
//

import UIKit
import Firebase

class GroupChatCollectionViewCell: BaseCell {
    
    var group: Post? {
        didSet {
            //print("group: ", group!)
            groupNameLabel.text = group!.postDescription
            supportersCountLabel.text = group!.supporterIds?.count.description ?? "0"
            if let groupImageUrl = group?.postImageUrl {
                if groupImageUrl == "" {
                    groupImageView.image = UIImage(named: "GroupPic1")
                } else {
                    //print("groupImageUrl: ", groupImageUrl)
                    groupImageView.loadImageUsingCacheWithUrlString(urlString: groupImageUrl)
                }
            }
        }
    }
    
    let groupImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "GroupPic1")
        return imageView
    }()
    
    let groupNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Group Name"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let supportersLabel: UILabel = {
        let label = UILabel()
        label.text = "Supporters"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = Utility.sharedInstance.mainGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let supportersCountLabel: UILabel = {
        let label = UILabel()
        label.text = "9"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 230, g: 230, b: 230)
        return view
    }()
    
    override func setupViews() {
        addSubview(groupImageView)
        addSubview(groupNameLabel)
        addSubview(supportersLabel)
        addSubview(supportersCountLabel)
        addSubview(separatorView)
        backgroundColor = UIColor.white
        
        addConstraintsWithFormat(format: "H:|-16-[v0(70)]-16-[v1]-8-|", views: groupImageView, groupNameLabel)
        addConstraintsWithFormat(format: "H:|-16-[v0(70)]-24-[v1]-8-[v2]", views: groupImageView, supportersLabel, supportersCountLabel)
        
        addConstraintsWithFormat(format: "V:|-16-[v0(70)]-16-[v1]|", views: groupImageView, separatorView)
        addConstraintsWithFormat(format: "V:|-18-[v0(24)]-8-[v1(20)]", views: groupNameLabel, supportersLabel)
        addConstraintsWithFormat(format: "V:|-18-[v0(24)]-8-[v1(20)]", views: groupNameLabel, supportersCountLabel)
        
        addConstraintsWithFormat(format: "H:|[v0]|", views: separatorView)
    }
}
