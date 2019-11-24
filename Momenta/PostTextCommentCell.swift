//
//  GDMemberTableViewCell.swift
//  humble
//
//  Created by Jonathon Fishman on 9/27/17.
//  Copyright © 2017 GoYoJo. All rights reserved.
//

import UIKit

class PostTextCommentCell: UITableViewCell {
    
    @IBOutlet weak var commentorImageView: UIImageView?
    @IBOutlet weak var commentorNameLabel: UILabel?
    @IBOutlet weak var commentTextView: UITextView?
    
    var optionsButtonClickCallback: ((String, String) -> Void)?
    var commentId = ""
    var commentorName = ""
    
    var item: Comment? {
        didSet {
            guard let item = item else {
                return
            }
            commentId = item.commentId!
            if let commentorImageUrl = item.commentorImageUrl {
                if commentorImageUrl != "" {
                    commentorImageView?.loadImageUsingCacheWithUrlString(urlString: commentorImageUrl)
                } else {
                    self.commentorImageView?.image = UIImage(named: "SmallProfileDefault")
                }
            } else {
                self.commentorImageView?.image = UIImage(named: "SmallProfileDefault")
            }
            if let name = item.commentorName {
                commentorNameLabel?.text = name
                commentorName = name
            }
            if let comment = item.comment {
                commentTextView?.isHidden = false
                commentTextView?.text = comment
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        commentorImageView?.layer.cornerRadius = 21
        commentorImageView?.clipsToBounds = true
        commentorImageView?.backgroundColor = .lightGray
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    @IBAction func onOptionsButton(_ sender: UIButton) {
        optionsButtonClickCallback?(commentId, commentorName)
    }
    
}
