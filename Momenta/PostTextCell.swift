//
//  PostTextCell.swift
//  humble
//
//  Created by Jonathon Fishman on 9/27/17.
//  Copyright © 2017 GoYoJo. All rights reserved.
//

import UIKit

class PostTextCell: UITableViewCell {

    @IBOutlet weak var postTextView: UITextView?
    
    var item: PostDetailViewModelItem? {
        didSet {
            guard let item = item as? PostDetailViewModelTextItem else {
                return
            }
            postTextView?.text = item.postText
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
