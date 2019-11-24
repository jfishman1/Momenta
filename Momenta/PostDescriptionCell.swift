//
//  PostDescriptionCell.swift 
//  humble
//
//  Created by Jonathon Fishman on 9/27/17.
//  Copyright © 2017 GoYoJo. All rights reserved.
//

import UIKit

class PostDescriptionCell: UITableViewCell {

    @IBOutlet weak var postCreatorImageView: UIImageView?
    @IBOutlet weak var postCreatorNameLabel: UILabel?
    @IBOutlet weak var postCategoryLabel: UILabel?
    @IBOutlet weak var postDescriptionTextView: UITextView?
    
    var item: PostDetailViewModelItem? {
        didSet {
            guard let item = item as? PostDetailViewModelDescriptionItem else {
                return
            }
            if item.creatorImageUrl != "" {
                Utility.sharedInstance.loadImageFromUrl(photoUrl: item.creatorImageUrl, completion: { data in
                    if let profileImage = UIImage(data: data) {
                        self.postCreatorImageView?.image = profileImage
                    }
                }, loadError: {print("error loading image from Url")
                    self.postCreatorImageView?.image = UIImage(named: "SmallProfileDefault")
                })
            } else {
                self.postCreatorImageView?.image = UIImage(named: "SmallProfileDefault")
            }
            let name = item.creatorName
            postCreatorNameLabel?.text = name
            
            let category = item.category
            postCategoryLabel?.text = category
            
            let postDescription = item.postDescription
            postDescriptionTextView?.text = postDescription
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        postCreatorImageView?.layer.cornerRadius = 21
        postCreatorImageView?.clipsToBounds = true
        postCreatorImageView?.backgroundColor = UIColor.lightGray
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        postCreatorImageView?.image = nil
    }

}
