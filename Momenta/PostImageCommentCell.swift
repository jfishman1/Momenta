//
//  PostImageCommentCell.swift
//  humble
//
//  Created by Jonathon Fishman on 4/8/18.
//  Copyright © 2018 GoYoJo. All rights reserved.
//

import UIKit

class PostImageCommentCell: UITableViewCell {
    
    @IBOutlet weak var commentorImageView: UIImageView?
    @IBOutlet weak var commentorNameLabel: UILabel?
    @IBOutlet weak var commentTextView: UITextView?
    @IBOutlet weak var commentImageView: UIImageView?
    
    var optionsButtonClickCallback: ((String, String) -> Void)?
    var commentId = ""
    var commentorName = ""
    
    var missingImage: UIImage?
    
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
            if let commentImageUrl = item.commentImageUrl {
                let characterCheck = String(commentImageUrl.prefix(5))
                if characterCheck != "https" {
                    commentImageView?.isHidden = false
                    commentImageView?.image = self.missingImage
                } else if commentImageUrl != "" {
                    commentImageView?.isHidden = false
                    commentImageView?.loadImageUsingCacheWithUrlString(urlString: commentImageUrl)
                }
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        commentorImageView?.layer.cornerRadius = 21
        commentorImageView?.clipsToBounds = true
        commentorImageView?.backgroundColor = .lightGray
        commentTextView?.isHidden = true
        commentImageView?.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if commentImageView?.image == missingImage {
            commentImageView?.image = missingImage
        }
        commentorImageView?.image = nil
        commentorImageView?.image = nil
        commentTextView?.isHidden = true
        commentImageView?.isHidden = true
    }
    @IBAction func onOptionsButton(_ sender: UIButton) {
        optionsButtonClickCallback?(commentId, commentorName)
    }
    
}
