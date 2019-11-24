//
//  PrivateChatCollectionViewCell.swift
//  humble
//
//  Created by Jonathon Fishman on 10/3/17.
//  Copyright © 2017 GoYoJo. All rights reserved.
//

import UIKit
import Firebase

class PrivateChatCollectionViewCell: BaseCell {
    
    var message: Message? {
        didSet {
            Cloud.sharedInstance.setupNameAndProfileImage(message: message!, completion: {name, profileImageUrl in
                self.nameTextLabel.text = name
                if profileImageUrl != "" {
                    self.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
                } else {
                    self.profileImageView.image = UIImage(named: "SmallProfileDefault")
                }
            })
            detailLabel.text = message?.text
            
            if let seconds = message?.timestamp?.doubleValue {
                let timestampDate = Date(timeIntervalSince1970: seconds)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                timeLabel.text = dateFormatter.string(from: timestampDate)
            }
        }
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let nameTextLabel: UILabel = {
       let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        nameLabel.textColor = UIColor.darkGray
        return nameLabel
    }()
    
    let detailLabel: UILabel = {
        let detailLabel = UILabel()
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.textColor = UIColor.lightGray
        detailLabel.numberOfLines = 3
        return detailLabel
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
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
        addSubview(profileImageView)
        addSubview(nameTextLabel)
        addSubview(detailLabel)
        addSubview(timeLabel)
        addSubview(separatorView)
        
        addConstraintsWithFormat(format: "H:|-16-[v0(48)]-16-[v1]-[v2]-|", views: profileImageView, nameTextLabel, timeLabel)
        addConstraintsWithFormat(format: "H:|-16-[v0(48)]-16-[v1]-8-|", views: profileImageView, detailLabel)
        
        addConstraintsWithFormat(format: "V:|-16-[v0(48)]", views: profileImageView)
        addConstraintsWithFormat(format: "V:|-16-[v0(20)]-8-[v1(22)]-6-[v2]|", views: nameTextLabel, detailLabel, separatorView)
        addConstraintsWithFormat(format: "V:|-18-[v0(24)]", views: timeLabel)
        
        addConstraintsWithFormat(format: "H:|[v0]|", views: separatorView)
    }
}


