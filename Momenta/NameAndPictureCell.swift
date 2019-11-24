//
//  NameAndPictureCell.swift
//  humble
//
//  Created by Jonathon Fishman on 2/18/18.
//  Copyright © 2018 GoYoJo. All rights reserved.
//

import UIKit

class NameAndPictureCell: UITableViewCell {
    
    @IBOutlet weak var editProfileImageView: UIImageView!
    @IBOutlet weak var bigProfileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    var item: ProfileViewModelItem? {
        didSet {
            guard let item = item as? ProfileViewModelNameItem else {
                return
            }
            let bigProfileImageUrl = item.profileImageUrl
            if bigProfileImageUrl == "" {
                bigProfileImageView.image = UIImage(named:"BigProfileDefault")
            } else {
                bigProfileImageView.loadImageUsingCacheWithUrlString(urlString: bigProfileImageUrl)
            }
            if item.isCurrentUser == true {
                editProfileImageView.isHidden = false
            }
            
            userNameLabel.text = item.userName
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = Utility.sharedInstance.mainGreen
        editProfileImageView.isHidden = true
        bigProfileImageView.layer.cornerRadius = 60
        bigProfileImageView.clipsToBounds = true
        //bigProfileImageView.layer.masksToBounds = true // same as clipsToBounds?
        bigProfileImageView.contentMode = .scaleAspectFill
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
