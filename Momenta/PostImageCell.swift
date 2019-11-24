//
//  PostImageCell.swift
//  humble
//
//  Created by Jonathon Fishman on 9/27/17.
//  Copyright © 2017 GoYoJo. All rights reserved.
//

import UIKit

class PostImageCell: UITableViewCell {

    @IBOutlet weak var postImageView: UIImageView?
    
    var item: PostDetailViewModelItem? {
        didSet {
            guard let item = item as? PostDetailViewModelImageItem else {
                return
            }
            let postImageUrl = item.postImageUrl
            if postImageUrl != "" {
                postImageView?.loadImageUsingCacheWithUrlString(urlString: postImageUrl)
            }
        }
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
