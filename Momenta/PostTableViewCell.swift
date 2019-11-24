//
//  PostTableViewCell.swift
//  humble
//
//  Created by Jonathon Fishman on 3/31/18.
//  Copyright © 2018 GoYoJo. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var supportersCountLabel: UILabel!
    @IBOutlet weak var momentumCountLabel: UILabel!
    
    var optionsButtonClickCallback: ((String, String) -> Void)?
    var postId = ""
    var name = ""
    
    var item: FindPostModelItem? {
        didSet {
            guard let item = item as? FindPostModelRegularPostItem else {
                return
            }
            let data = item.regularPostData
            postId = data.postId
            let category = data.category
            categoryLabel.text = category
            let postDescription = data.postDescription
            descriptionTextView.text = postDescription
            descriptionTextView.sizeToFit()

            let imageUrl = data.creatorImageUrl
            if imageUrl == "" {
                profileImageView.image = UIImage(named: "BigProfileDefault")
            } else {
                profileImageView.loadImageUsingCacheWithUrlString(urlString: imageUrl)
            }
            name = data.creatorName
            if name == "" {
                nameLabel.text = "Jon"
            } else {
                nameLabel.text = name
            }
            
            let supportersCount = data.supportersCount
            if supportersCount > 10000000 {
                supportersCountLabel.text = "10MM+"
            } else {
                supportersCountLabel.text = supportersCount.description
            }
            supportersCountLabel.sizeToFit()
            
            let momentumCount = data.momentumCount
            if momentumCount > 10000000 {
                momentumCountLabel.text = "10MM+"
            } else {
                momentumCountLabel.text = momentumCount.description
            }
            momentumCountLabel.sizeToFit()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImageView.backgroundColor = UIColor.darkGray
        profileImageView.layer.cornerRadius = 21
        profileImageView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView?.image = nil
    }
    
    @IBAction func onOptionsButton(_ sender: UIButton) {
        optionsButtonClickCallback?(postId, name)
    }
    
    

}
