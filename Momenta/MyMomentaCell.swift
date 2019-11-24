//
//  OtherMovementsCell.swift
//  humble
//
//  Created by Jonathon Fishman on 2/18/18.
//  Copyright © 2018 GoYoJo. All rights reserved.
//

import UIKit

class MyMomentaCell: UITableViewCell {

    @IBOutlet weak var commentImageView: UIImageView!
    @IBOutlet weak var commentNameLabel: UILabel!
    
    var item: Comment? {
        didSet {
            guard let item = item else {
                return
            }
            if let commentImageUrl = item.commentImageUrl {
                if commentImageUrl == "" {
                    commentImageView?.image = UIImage(named: "GroupPic1")
                } else {
                    commentImageView?.loadImageUsingCacheWithUrlString(urlString: commentImageUrl)
                }
            } else {
                commentImageView?.image = UIImage(named: "GroupPic1")
            }
            commentNameLabel.text = item.comment
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        commentImageView.image = nil
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
