//
//  MyMovementsCell.swift
//  humble
//
//  Created by Jonathon Fishman on 2/18/18.
//  Copyright © 2018 GoYoJo. All rights reserved.
//

import UIKit

class MyActionsCell: UITableViewCell {

    @IBOutlet weak var actionImageView: UIImageView!
    @IBOutlet weak var actionNameLabel: UILabel!
    
    var item: Post? {
        didSet {
            guard let item = item else {
                return
            }
            if let postImageUrl = item.postImageUrl {
                if postImageUrl == "" {
                    actionImageView?.image = UIImage(named: "GroupPic1")
                } else {
                    actionImageView?.loadImageUsingCacheWithUrlString(urlString: postImageUrl)
                }
            } else {
                actionImageView?.image = UIImage(named: "GroupPic1")
            }
            actionNameLabel.text = item.postDescription
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        actionImageView.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
