//
//  GD7TableViewCell.swift
//  humble
//
//  Created by Jonathon Fishman on 10/28/17.
//  Copyright © 2017 GoYoJo. All rights reserved.
//

import UIKit

class PostActionsCell: UITableViewCell {
    
    @IBOutlet weak var supportersLabel: UILabel?
    @IBOutlet weak var supportButton: UIButton?
    @IBOutlet weak var momentumLabel: UILabel?
    @IBOutlet weak var momentumButton: UIButton?
    
    var supportButtonClickCallback: (() -> Void)?
    var momentumButtonClickCallback: (() -> Void)?
    
    var isCurrentPostSupporter: Bool?
    var numberOfSupporters: Int?
    
    var item: PostDetailViewModelItem? {
        didSet {
            guard let item = item as? PostDetailViewModelActionsItem else {
                return
            }
            isCurrentPostSupporter = item.isCurrentPostSupporter
            let supportersCount = item.supportersCount
            numberOfSupporters = supportersCount
            if supportersCount == 1 {
                supportButton?.setTitle("Supporter", for: .normal)
            } else {
                supportButton?.setTitle("Supporters", for: .normal)
            }
            supportersLabel?.text = supportersCount.description
            momentumLabel?.text = item.momentumCount.description
        }
    }
    
    func updateSupportersLabelAndButton() {
        if supportersLabel?.textColor != .orange {
            var supportersCount = numberOfSupporters ?? 0
            supportersCount += 1
            supportersLabel!.text = String(supportersCount)
            supportButton?.setTitleColor(.orange, for: .normal)
            supportersLabel?.textColor = .orange
            supportersLabel?.updateConstraintsIfNeeded()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onSupportButton(_ sender: UIButton) {
        supportButtonClickCallback?()
    }
    @IBAction func onMomentumButton(_ sender: UIButton) {
        momentumButtonClickCallback?()
    }
    
}
