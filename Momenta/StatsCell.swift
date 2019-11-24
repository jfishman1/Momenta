//
//  StatsCell.swift
//  humble
//
//  Created by Jonathon Fishman on 2/18/18.
//  Copyright © 2018 GoYoJo. All rights reserved.
//

import UIKit

class StatsCell: UITableViewCell {

    @IBOutlet weak var actionsCountLabel: UILabel!
    @IBOutlet weak var momentaCountLabel: UILabel!
    @IBOutlet weak var supportersCountLabel: UILabel!
    
    var item: ProfileViewModelItem? {
        didSet {
            guard let item = item as? ProfileViewModelStatsItem else {
                return
            }
            let actionsCount = item.actionsCount
            let momentaCount = item.momentaCount
            let supportersCount = item.supportersCount
            
            if momentaCount >= 10000000 {
                momentaCountLabel.text = "10 MM+"
            } else {
                momentaCountLabel.text = momentaCount.description
            }
            
            if actionsCount >= 10000000 {
                actionsCountLabel.text = "10 MM+"
            } else {
                actionsCountLabel.text = actionsCount.description
            }
            
            if supportersCount >= 10000000 {
                supportersCountLabel.text = "10 MM+"
            } else {
                supportersCountLabel.text = supportersCount.description
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
